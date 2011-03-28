require 'enumerator'

##
# Pasteboard wraps the OS X pasteboard (clipboard) allowing you to paste
# multiple flavors of a pasteboard item.  Currently it only supports the
# general clipboard.
#
# To add data to the clipboard:
#
#   item = [
#     Pasteboard::Type::UTF_8,      'π'],
#     Pasteboard::Type::PLAIN_TEXT, 'pi'],
#   ]
#
#   pasteboard.put item
#
# To retrieve data from the clipboard:
#
#   data = pasteboard.first Pasteboard::Type::UTF_8
#
# If the item cannot be found nil will be returned.
#
# See #put, #first and #[] for more details

class Pasteboard

  ##
  # Pasteboard error class

  class Error < RuntimeError
  end

  ##
  # Missing is raised when attempting to access an item that does not exist

  class Missing < Error
  end

  ##
  # Version of pasteboard

  VERSION = '1.0'

  if defined? Encoding then
    BE_BOM = "\xFE\xFF" # :nodoc:
    LE_BOM = "\xFF\xFE" # :nodoc:

    BE_BOM.force_encoding Encoding::BINARY
    LE_BOM.force_encoding Encoding::BINARY

    little = [1].pack('S') == "\001\000" ? true : false

    NATIVE_BOM      = little ? LE_BOM             : BE_BOM
    NATIVE_ENCODING = little ? Encoding::UTF_16LE : Encoding::UTF_16BE
  end

  ##
  # General clipboard pasteboard type.  Cut, copy and paste use this
  # pasteboard.

  CLIPBOARD = 'com.apple.pasteboard.clipboard'

  ##
  # Find pasteboard type.  Find and find and replace use this pasteboard.

  FIND = 'com.apple.pasteboard.find'

  ##
  # A uniquely named pasteboard type.

  UNIQUE = nil

  ##
  # Synchronizes the pasteboard and returns the item at +index+ in the
  # pasteboard.
  #
  # If +flavor+ is given only the given flavor's data is returned.  If no
  # flavor matches nil is returned.
  #
  # An item is an Array of pairs in the order of preference which looks like
  # this:
  #
  #   [
  #     ["public.utf8-plain-text", "Pasteboard"],
  #     ["public.utf16-external-plain-text",
  #      "\377\376P\000a\000s\000t\000e\000b\000o\000a\000r\000d\000"],
  #     ["com.apple.traditional-mac-plain-text", "Pasteboard"],
  #     ["public.utf16-plain-text",
  #      "P\000a\000s\000t\000e\000b\000o\000a\000r\000d\000"],
  #   ]

  def [] index, flavor = nil
    flags = sync

    raise Error, 'pasteboard sync error' if (flags & MODIFIED) != 0

    id = get_item_identifier index + 1

    get id, flavor
  rescue Missing => e
    return nil
  end

  ##
  # Synchronizes the pasteboard and yields each item in the pasteboard.
  #
  # If +flavor+ is given only the given flavor's data is yielded.  If no
  # flavor matches nil is yielded.
  #
  # See #[] for a description of an item.

  def each flavor = nil # :yields: item
    unless block_given? then
      enum = defined?(Enumerator) ? Enumerator : Enumerable::Enumerator # 1.8.7
      return enum.new(self, :each, flavor)
    end

    flags = sync

    raise Error, 'pasteboard sync error' if (flags & MODIFIED) != 0

    ids.each do |id|
      yield get(id, flavor)
    end

    self
  end

  ##
  # Retrieves the first item in the pasteboard.
  #
  # If +flavor+ is given only the given flavor's data is returned.  If no
  # flavor matches nil is returned.
  #
  # See #[] for a description of an item.

  def first flavor = nil
    self[0, flavor]
  end

  ##
  # Returns the item with +id+ in the pasteboard.
  #
  # If +flavor+ is given only the given flavor's data is returned.  If no
  # flavor matches nil is returned.
  #
  # See #[] for a description of an item.

  def get id, flavor = nil
    item = copy_item_flavors(id).map do |item_flavor|
      if flavor then
        return copy_item_flavor_data(id, item_flavor) if item_flavor == flavor
        next
      end

      [item_flavor, copy_item_flavor_data(id, item_flavor)]
    end

    return nil if item.compact.empty?

    item
  end

  ##
  # An array of item ids in the pasteboard.  You must sync the clipboard to
  # get the latest ids.

  def ids
    (1..get_item_count).map do |index|
      get_item_identifier index
    end
  end

  def inspect # :nodoc:
    '#<%s:0x%x %s>' % [self.class, object_id, name]
  end

  ##
  # Clears the pasteboard and adds +items+ to the pasteboard.  Each item is
  # added with a consecutive id starting at 0.
  #
  # An item must be an Enumerable with pairs of item flavors and items.  For
  # example:
  #
  #   item = [
  #     [Pasteboard::Type::TIFF,     tiff],
  #     [Pasteboard::Type::URL,      url],
  #     [Pasteboard::Type::URL_NAME, url],
  #     [Pasteboard::Type::UTF_8,    url],
  #   ]
  #
  #   pasteboard.put item
  #
  # The pasteboard considers flavors added earlier in an item to have a higher
  # preference.

  def put *items
    clear
    flags = sync

    raise Error, 'pasteboard sync error' if (flags & MODIFIED)        != 0
    raise Error, 'pasteboard not owned'  if (flags & CLIENT_IS_OWNER) == 0

    items.each_with_index do |item, id|
      item.each do |flavor, data|
        put_item_flavor id, flavor, data
      end
    end

    self
  end

  ##
  # Adds +url+ to the pasteboard with an optional +url_name+.

  def put_url url, url_name = url
    item = [
      [Pasteboard::Type::URL,      url],
      [Pasteboard::Type::URL_NAME, url_name],
      [Pasteboard::Type::UTF_8,    url],
    ]

    put item
  end

  ##
  # Adds JPEG data +image+ to the pasteboard with a +url+ and optional
  # +url_name+.

  def put_jpeg_url image, url, url_name = url
    item = [
      [Pasteboard::Type::JPEG,     image],
      [Pasteboard::Type::URL,      url],
      [Pasteboard::Type::URL_NAME, url_name],
      [Pasteboard::Type::UTF_8,    url],
    ]

    put item
  end

end

require 'pasteboard/type'
require 'pasteboard/pasteboard'

