require 'pasteboard/pasteboard'
require 'enumerator'

##
# Pasteboard wraps the OS X pasteboard (clipboard) allowing you to paste
# multiple flavors of a pasteboard item.  Currently it only supports the
# general clipboard.

class Pasteboard

  ##
  # Version of pasteboard

  VERSION = '1.0'

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
  end

  ##
  # Synchronizes the pasteboard and yields each item in the pasteboard.
  #
  # If +flavor+ is given only the given flavor's data is yielded.  If no
  # flavor matches nil is yielded.
  #
  # See #[] for a description of an item.

  def each flavor = nil # :yields: item
    return Enumerator.new(self, :each, flavor) unless block_given?

    flags = sync

    raise Error, 'pasteboard sync error' if (flags & MODIFIED) != 0

    ids.each do |id|
      yield get(id, flavor)
    end

    self
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
      return copy_item_flavor_data(id, item_flavor) if
        flavor and item_flavor == flavor

      [item_flavor, copy_item_flavor_data(id, item_flavor)]
    end

    return nil if item.empty?

    item
  end

  def inspect # :nodoc:
    '#<%s:0x%x %s>' % [self.class, object_id, name]
  end

  ##
  # An array of item ids in the pasteboard.  You must sync the clipboard to
  # get the latest ids.

  def ids
    (1..get_item_count).map do |index|
      get_item_identifier index
    end
  end

  ##
  # Clears the pasteboard and adds +item+ to the pasteboard with +id+.
  #
  # +item+ must be an Enumerable with pairs of item flavors and items.  For
  # example:
  #
  #   item = [
  #     ['public.tiff',            tiff],
  #     ['public.url',             url],
  #     ['public.url-name',        url],
  #     ['public.utf8-plain-text', url]
  #   ]
  #
  #   pasteboard.put item
  #
  # The pasteboard considers items added earlier in the list to have a higher
  # preference.

  def put item, id = 0
    clear
    flags = sync

    raise Error, 'pasteboard sync error' if (flags & MODIFIED)        != 0
    raise Error, 'pasteboard not owned'  if (flags & CLIENT_IS_OWNER) == 0

    item.each do |flavor, data|
      put_item_flavor id, flavor, data
    end
  end

  autoload :Type, 'pasteboard/type'

end

