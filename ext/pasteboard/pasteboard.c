#include <ruby.h>
#include <Pasteboard.h>
#include "extconf.h"

#define BUFSIZE 128

static VALUE cPB;
static VALUE cPBType;
static VALUE cPBTypeEncodings;
static VALUE ePBError;

#if HAVE_RB_STR_ENCODE
#include <ruby/encoding.h>

static VALUE BE_BOM;
static VALUE LE_BOM;

static VALUE binary_encoding;
static VALUE usascii_encoding;
static VALUE utf8_encoding;
static VALUE utf16be_encoding;
static VALUE utf16le_encoding;
static VALUE native_encoding;

static VALUE utf16_external_flavor;
static VALUE utf16_internal_flavor;
#endif

static VALUE
string_ref_to_value(CFStringRef ref) {
  VALUE string = Qnil;
  char buffer[BUFSIZE];
  const char * str = NULL;

  str = CFStringGetCStringPtr(ref, kCFStringEncodingUTF8);

  if (str == NULL)
    if (CFStringGetCString(ref, buffer, BUFSIZE, kCFStringEncodingUTF8))
      str = buffer;

  if (str == NULL) /* HACK buffer was too small */
      return Qnil;

  string = rb_str_new2(str);

#if HAVE_RB_STR_ENCODE
  rb_enc_associate(string, rb_to_encoding(utf8_encoding));
#endif

  return string;
}

static char *
value_to_usascii_cstr(VALUE string) {
#if HAVE_RB_STR_ENCODE
  string = rb_str_encode(string, usascii_encoding, 0, Qnil);
#endif

  return StringValueCStr(string);
}

static char *
value_to_utf8_cstr(VALUE string) {
#if HAVE_RB_STR_ENCODE
  string = rb_str_encode(string, utf8_encoding, 0, Qnil);
#endif

  return StringValueCStr(string);
}

#if HAVE_RB_STR_ENCODE
static void
handle_bom(VALUE data, VALUE default_encoding) {
  VALUE bom;

  rb_enc_associate(data, rb_to_encoding(binary_encoding));
  bom = rb_str_substr(data, 0, 2);

  if (rb_str_equal(bom, BE_BOM)) {
    rb_enc_associate(data, rb_to_encoding(utf16be_encoding));
  } else if (rb_str_equal(bom, LE_BOM)) {
    rb_enc_associate(data, rb_to_encoding(utf16le_encoding));
  } else {
    rb_enc_associate(data, rb_to_encoding(default_encoding));
  }
}
#endif

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
  const char * message = NULL;
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
        value_to_utf8_cstr(type),
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
 *   pasteboard.copy_item_flavor_data identifier, flavor
 *
 * Retrieves pasteboard data from +identifier+ of +flavor+
 */
static VALUE
pb_copy_item_flavor_data(VALUE self, VALUE identifier, VALUE flavor) {
  OSStatus err = noErr;
  PasteboardRef pasteboard;
  PasteboardItemID id = 0;
  CFIndex data_length = 0;
  CFDataRef flavor_data = NULL;
  CFStringRef flavor_type = NULL;
  UInt8 *buffer = NULL;
  VALUE data = Qnil;
  VALUE encoding = Qnil;
  VALUE encodings = Qnil;

  pasteboard = pb_get_pasteboard(self);

  id = (PasteboardItemID)NUM2ULONG(identifier);

  flavor_type = CFStringCreateWithCString(NULL,
      value_to_usascii_cstr(flavor),
      kCFStringEncodingASCII);

  if (flavor_type == NULL)
    rb_raise(ePBError, "unable to allocate memory for flavor type");

  err = PasteboardCopyItemFlavorData(pasteboard, id, flavor_type, &flavor_data);

  pb_error(err);

  data_length = CFDataGetLength(flavor_data);

  buffer = (UInt8 *)malloc(data_length);

  if (buffer == NULL) {
    CFRelease(flavor_data);
    rb_raise(ePBError, "unable to allocate memory for data");
  }

  CFDataGetBytes(flavor_data, CFRangeMake(0, data_length), buffer);

  CFRelease(flavor_data);

  data = rb_str_new(buffer, data_length);

  free(buffer);

#if HAVE_RB_STR_ENCODE
  encoding = rb_hash_aref(cPBTypeEncodings, flavor);

  if (rb_str_equal(flavor, utf16_external_flavor) ||
      rb_str_equal(flavor, utf16_internal_flavor)) {
    handle_bom(data, encoding);
  } else {
    rb_enc_associate(data, rb_to_encoding(encoding));
  }
#endif

  return data;
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

  return ULONG2NUM(flags);
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
      value_to_usascii_cstr(flavor),
      kCFStringEncodingASCII);

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
  cPB = rb_define_class("Pasteboard", rb_cObject);

  cPBType          = rb_const_get_at(cPB,     rb_intern("Type"));
  cPBTypeEncodings = rb_const_get_at(cPBType, rb_intern("Encodings"));
  ePBError         = rb_const_get_at(cPB,     rb_intern("Error"));

#if HAVE_RB_STR_ENCODE
  utf8_encoding    = rb_enc_from_encoding(rb_utf8_encoding());
  binary_encoding  = rb_const_get_at(rb_cEncoding, rb_intern("BINARY"));
  utf16be_encoding = rb_const_get_at(rb_cEncoding, rb_intern("UTF_16BE"));
  utf16le_encoding = rb_const_get_at(rb_cEncoding, rb_intern("UTF_16LE"));
  native_encoding  = rb_const_get_at(cPB, rb_intern("NATIVE_ENCODING"));
  usascii_encoding = rb_enc_from_encoding(rb_usascii_encoding());

  utf16_external_flavor = rb_const_get_at(cPBType,
      rb_intern("PLAIN_TEXT_UTF16_EXTERNAL"));

  utf16_internal_flavor = rb_const_get_at(cPBType,
      rb_intern("PLAIN_TEXT_UTF16"));

  BE_BOM = rb_const_get_at(cPB, rb_intern("BE_BOM"));
  LE_BOM = rb_const_get_at(cPB, rb_intern("LE_BOM"));
#endif

  rb_define_const(cPB, "MODIFIED",        ULONG2NUM(kPasteboardModified));
  rb_define_const(cPB, "CLIENT_IS_OWNER", ULONG2NUM(kPasteboardClientIsOwner));

  rb_define_alloc_func(cPB, pb_alloc);
  rb_define_method(cPB, "initialize",            pb_init,                  -1);
  rb_define_method(cPB, "clear",                 pb_clear,                  0);
  rb_define_method(cPB, "copy_item_flavors",     pb_copy_item_flavors,      1);
  rb_define_method(cPB, "copy_item_flavor_data", pb_copy_item_flavor_data,  2);
  rb_define_method(cPB, "get_item_count",        pb_get_item_count,         0);
  rb_define_method(cPB, "get_item_identifier",   pb_get_item_identifier,    1);
  rb_define_method(cPB, "name",                  pb_name,                   0);
  rb_define_method(cPB, "put_item_flavor",       pb_put_item_flavor,        3);
  rb_define_method(cPB, "sync",                  pb_sync,                   0);
}

