#include <ruby.h>
#include <Pasteboard.h>

static VALUE ePBError;

static VALUE
pb_alloc(VALUE klass) {
  VALUE obj;
  OSStatus err = noErr;
  PasteboardRef clipboard;

  err = PasteboardCreate(kPasteboardClipboard, &clipboard);

  if (err != noErr)
    rb_raise(ePBError, "error initializing the clipboard");

  obj = Data_Wrap_Struct(klass, NULL, NULL, (void*)clipboard);

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
 *   pasteboard.clear
 *
 * Clears the contents of the pasteboard.
 */
static VALUE
pb_clear(VALUE self) {
  OSStatus err = noErr;
  PasteboardRef clipboard;

  clipboard = pb_get_pasteboard(self);

  err = PasteboardClear(clipboard);

  pb_error(err);

  return self;
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
  PasteboardRef clipboard;

  clipboard = pb_get_pasteboard(self);

  flags = PasteboardSynchronize(clipboard);

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
 * +flavor+ is the item's type and +data+ is the clipboard data for the item.
 */

static VALUE
pb_put_item_flavor(VALUE self, VALUE id, VALUE flavor, VALUE data) {
  OSStatus err = noErr;
  PasteboardRef clipboard;
  CFDataRef clipboard_data = NULL;
  CFStringRef item_flavor = NULL;

  clipboard = pb_get_pasteboard(self);

  item_flavor = CFStringCreateWithCString(NULL,
      StringValueCStr(flavor),
      kCFStringEncodingUTF8);

  if (item_flavor == NULL)
    rb_raise(ePBError, "unable to allocate memory for item flavor");

  clipboard_data = CFDataCreate(kCFAllocatorDefault,
      (UInt8 *)StringValuePtr(data), RSTRING_LEN(data));

  if (clipboard_data == NULL) {
    CFRelease(item_flavor);
    rb_raise(ePBError, "unable to allocate memory for clipboard data");
  }

  err = PasteboardPutItemFlavor(clipboard,
      (PasteboardItemID)NUM2ULONG(id),
      item_flavor,
      clipboard_data,
      kPasteboardFlavorNoFlags);

  CFRelease(item_flavor);
  CFRelease(clipboard_data);

  pb_error(err);

  return self;
}

void
Init_pasteboard(void) {
  VALUE cPB = rb_define_class("Pasteboard", rb_cObject);
  ePBError = rb_define_class_under(cPB, "Error", rb_eRuntimeError);

  rb_define_alloc_func(cPB, pb_alloc);
  rb_define_method(cPB, "clear",           pb_clear,           0);
  rb_define_method(cPB, "put_item_flavor", pb_put_item_flavor, 3);
  rb_define_method(cPB, "sync",            pb_sync,            0);
}

