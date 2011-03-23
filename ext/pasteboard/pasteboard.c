#include <ruby.h>
#include <Pasteboard.h>

#define BUFSIZE 128

static VALUE ePBError;

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
 *   pasteboard.name
 *
 * The name of this pasteboard.
 */
static VALUE
pb_name(VALUE self) {
  OSStatus err = noErr;
  PasteboardRef pasteboard;
  CFStringRef pasteboard_name = NULL;
  char buffer[BUFSIZE];
  const char *name = NULL;

  pasteboard = pb_get_pasteboard(self);

  err = PasteboardCopyName(pasteboard, &pasteboard_name);

  pb_error(err);

  name = CFStringGetCStringPtr(pasteboard_name, kCFStringEncodingUTF8);

  if (name == NULL)
    if (CFStringGetCString(pasteboard_name, buffer, BUFSIZE,
          kCFStringEncodingUTF8))
      name = buffer;

  if (name == NULL) /* HACK buffer was too small */
      return Qnil;

  return rb_str_new2(name);
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
  rb_define_method(cPB, "initialize",      pb_init,            -1);
  rb_define_method(cPB, "clear",           pb_clear,            0);
  rb_define_method(cPB, "name",            pb_name,             0);
  rb_define_method(cPB, "put_item_flavor", pb_put_item_flavor,  3);
  rb_define_method(cPB, "sync",            pb_sync,             0);
}

