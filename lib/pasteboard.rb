require 'pasteboard/pasteboard'

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
  # Clears the pasteboard and adds +item+ to the pasteboard at item +id+.
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
    sync

    item.each do |flavor, data|
      put_item_flavor id, flavor, data
    end
  end

  autoload :Type, 'pasteboard/type'

end

