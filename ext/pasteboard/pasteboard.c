#include <ruby.h>
#include <Pasteboard.h>

#define BUFSIZE 128

static VALUE ePBError;

static VALUE
string_ref_to_value(CFStringRef ref) {
  char buffer[BUFSIZE];
  const char * string = NULL;

  string = CFStringGetCStringPtr(ref, kCFStringEncodingUTF8);

  if (string == NULL)
    if (CFStringGetCString(ref, buffer, BUFSIZE, kCFStringEncodingUTF8))
      string = buffer;

  if (string == NULL) /* HACK buffer was too small */
      return Qnil;

  return rb_str_new2(string);
}

static void pb_free(void *ptr) {
  if (ptr)
    CFRelease((PasteboardRef)ptr);
}

static VALUE
pb_alloc(VALUE klass) {
  VALUE obj;

  obj = Data_Wrap_Struct(klass, NULL, pb_free, NULL);

  return obj;
}

static void
pb_error(OSStatus err) {
  char * message = NULL;
  switch (err) {
    case noErr:
      return;
    case badPasteboardSyncErr:
      message = "pasteboard has been modified and must be synchronized before use";
      break;
    case badPasteboardIndexErr:
      message = "pasteboard item does not exist";
      break;
    case badPasteboardItemErr:
      message = "item reference does not exist";
      break;
    case badPasteboardFlavorErr:
      message = "item flavor does not exist";
      break;
    case duplicatePasteboardFlavorErr:
      message = "item flavor already exists";
      break;
    case notPasteboardOwnerErr:
      message = "pasteboard was not cleared before attempting to add flavor data";
      break;
    case noPasteboardPromiseKeeperErr:
      message = "promised data was added without registering a promise keeper callback";
      break;
    default:
      message = "unknown";
      break;
  }

  rb_raise(ePBError, message);
}

static PasteboardRef
pb_get_pasteboard(VALUE obj) {
  Check_Type(obj, T_DATA);
  return (PasteboardRef)DATA_PTR(obj);
}

/*
 * call-seq:
 *   Pasteboard.new type = Pasteboard::CLIPBOARD
 *
 * Creates a new pasteboard of the specified +type+.
 */
static VALUE
pb_init(int argc, VALUE* argv, VALUE self) {
  OSStatus err = noErr;
  PasteboardRef pasteboard;
  CFStringRef pasteboard_type = NULL;
  VALUE type = Qnil;

  if (argc == 0) {
    pasteboard_type = kPasteboardClipboard;
  } else {
    rb_scan_args(argc, argv, "01", &type);
  }

  if (!NIL_P(type)) {
    pasteboard_type = CFStringCreateWithCString(NULL,
        StringValueCStr(type),
        kCFStringEncodingUTF8);

    if (pasteboard_type == NULL)
      rb_raise(ePBError, "unable to allocate memory for pasteboard type");
  }

  err = PasteboardCreate(pasteboard_type, &pasteboard);

  if (pasteboard_type)
    CFRelease(pasteboard_type);

  pb_error(err);

  DATA_PTR(self) = (void *)pasteboard;

  return self;
}

/*
 * call-seq:
 *   pasteboard.clear
 *
 * Clears the contents of the pasteboard.
 */
static VALUE
pb_clear(VALUE self) {
  OSStatus err = noErr;
  PasteboardRef pasteboard;

  pasteboard = pb_get_pasteboard(self);

  err = PasteboardClear(pasteboard);

  pb_error(err);

  return self;
}

/*
 * call-seq:
 *   pasteboard.copy_item_flavors identifier
 *
 * Returns an Array of flavors for the pasteboard item at +identifier+.
 */
static VALUE
pb_copy_item_flavors(VALUE self, VALUE identifier) {
  OSStatus err = noErr;
  PasteboardRef pasteboard;
  PasteboardItemID item_id;
  CFArrayRef flavor_types = NULL;
  CFIndex i, flavor_count = 0;
  VALUE flavors = Qnil;

  item_id = (PasteboardItemID)NUM2ULONG(identifier);

  pasteboard = pb_get_pasteboard(self);

  err = PasteboardCopyItemFlavors(pasteboard, item_id, &flavor_types);

  pb_error(err);

  flavors = rb_ary_new();

  flavor_count = CFArrayGetCount(flavor_types);

  for (i = 0; i < flavor_count; i++) {
    CFStringRef flavor_type =
      (CFStringRef)CFArrayGetValueAtIndex(flavor_types, i);

    rb_ary_push(flavors, string_ref_to_value(flavor_type));
  }

  CFRelease(flavor_types);

  return flavors;
}

/*
 * call-seq:
 *   pasteboard.get_item_count
 *
 * The number of items on the pasteboard
 */
static VALUE
pb_get_item_count(VALUE self) {
  OSStatus err = noErr;
  PasteboardRef pasteboard;
  ItemCount item_count = 0;

  pasteboard = pb_get_pasteboard(self);

  err = PasteboardGetItemCount(pasteboard, &item_count);

  pb_error(err);

  return ULONG2NUM(item_count);
}

/*
 * call-seq:
 *   pasteboard.get_item_identifier index
 *
 * The identifier of the pasteboard item at +index+ which is 1-based.
 */
static VALUE
pb_get_item_identifier(VALUE self, VALUE index) {
  OSStatus err = noErr;
  PasteboardRef pasteboard;
  CFIndex item_index = 0;
  PasteboardItemID item_id = 0;

  item_index = NUM2ULONG(index);

  pasteboard = pb_get_pasteboard(self);

  err = PasteboardGetItemIdentifier(pasteboard, item_index, &item_id);

  pb_error(err);

  return ULONG2NUM((unsigned long)item_id);
}

/*
 * call-seq:
 *   pasteboard.name
 *
 * The name of this pasteboard.
 */
static VALUE
pb_name(VALUE self) {
  OSStatus err = noErr;
  PasteboardRef pasteboard;
  CFStringRef pasteboard_name = NULL;
  VALUE name = Qnil;

  pasteboard = pb_get_pasteboard(self);

  err = PasteboardCopyName(pasteboard, &pasteboard_name);

  pb_error(err);

  name = string_ref_to_value(pasteboard_name);

  if (pasteboard_name)
    CFRelease(pasteboard_name);

  return name;
}

/*
 * call-seq:
 *   pasteboard.sync
 *
 * Synchronizes the local pasteboard to reflect the contents of the global
 * pasteboard.
 */
static VALUE
pb_sync(VALUE self) {
  OSStatus err = noErr;
  PasteboardSyncFlags flags;
  PasteboardRef pasteboard;

  pasteboard = pb_get_pasteboard(self);

  flags = PasteboardSynchronize(pasteboard);

  if (flags & kPasteboardModified)
    rb_raise(ePBError, "pasteboard sync error");

  if (!(flags & kPasteboardClientIsOwner))
    rb_raise(ePBError, "pasteboard not owned");

  return self;
}

/*
 * call-seq:
 *   pasteboard.put_item_flavor id, flavor, data
 *
 * Puts an item into the pasteboard.  +id+ is used to identify an item,
 * +flavor+ is the item's type and +data+ is the pasteboard data for the item.
 */
static VALUE
pb_put_item_flavor(VALUE self, VALUE id, VALUE flavor, VALUE data) {
  OSStatus err = noErr;
  PasteboardRef pasteboard;
  CFDataRef pasteboard_data = NULL;
  CFStringRef item_flavor = NULL;

  pasteboard = pb_get_pasteboard(self);

  item_flavor = CFStringCreateWithCString(NULL,
      StringValueCStr(flavor),
      kCFStringEncodingUTF8);

  if (item_flavor == NULL)
    rb_raise(ePBError, "unable to allocate memory for item flavor");

  pasteboard_data = CFDataCreate(kCFAllocatorDefault,
      (UInt8 *)StringValuePtr(data), RSTRING_LEN(data));

  if (pasteboard_data == NULL) {
    CFRelease(item_flavor);
    rb_raise(ePBError, "unable to allocate memory for pasteboard data");
  }

  err = PasteboardPutItemFlavor(pasteboard,
      (PasteboardItemID)NUM2ULONG(id),
      item_flavor,
      pasteboard_data,
      kPasteboardFlavorNoFlags);

  CFRelease(item_flavor);
  CFRelease(pasteboard_data);

  pb_error(err);

  return self;
}

void
Init_pasteboard(void) {
  VALUE cPB = rb_define_class("Pasteboard", rb_cObject);
  ePBError = rb_define_class_under(cPB, "Error", rb_eRuntimeError);

  rb_define_alloc_func(cPB, pb_alloc);
  rb_define_method(cPB, "initialize",          pb_init,                -1);
  rb_define_method(cPB, "clear",               pb_clear,                0);
  rb_define_method(cPB, "copy_item_flavors",   pb_copy_item_flavors,    1);
  rb_define_method(cPB, "get_item_count",      pb_get_item_count,       0);
  rb_define_method(cPB, "get_item_identifier", pb_get_item_identifier,  1);
  rb_define_method(cPB, "name",                pb_name,                 0);
  rb_define_method(cPB, "put_item_flavor",     pb_put_item_flavor,      3);
  rb_define_method(cPB, "sync",                pb_sync,                 0);
}

