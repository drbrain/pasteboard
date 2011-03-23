require 'pasteboard'

troll_tiff = %w[
4d 4d 00 2a 00 00 04 08 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 ff 00 00
00 ff 00 00 00 ff 00 00 00 ff 00 00 00 ff 00
00 00 ff 00 00 00 ff 00 00 00 ff 00 00 00 ff
00 00 00 ff 00 00 00 ff 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 ff ff ff
ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
ff ff ff ff ff ff ff ff ff ff ff ff 00 00 00
ff 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 ff ff ff ff ff ff ff ff ff ff ff ff ff ff
ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
ff 00 00 00 ff 00 00 00 00 00 00 00 00 00 00
00 ff ff ff ff ff 00 00 00 ff 00 00 00 ff 00
00 00 ff ff ff ff ff 00 00 00 ff 00 00 00 ff
00 00 00 ff 00 00 00 ff ff ff ff ff ff ff ff
ff ff ff ff ff ff ff ff ff 00 00 00 ff 00 00
00 00 00 00 00 ff ff ff ff ff ff ff ff ff 00
00 00 ff 00 00 00 ff ff ff ff ff ff ff ff ff
ff ff ff ff 00 00 00 ff 00 00 00 ff ff ff ff
ff 00 00 00 ff 00 00 00 ff ff ff ff ff ff ff
ff ff 00 00 00 ff 00 00 00 00 00 00 00 ff ff
ff ff ff 00 00 00 ff ff ff ff ff ff ff ff ff
00 00 00 ff ff ff ff ff ff ff ff ff ff ff ff
ff ff ff ff ff ff ff ff ff 00 00 00 ff 00 00
00 ff ff ff ff ff 00 00 00 ff 00 00 00 00 00
00 00 ff ff ff ff ff ff ff ff ff 00 00 00 ff
00 00 00 ff ff ff ff ff ff ff ff ff ff ff ff
ff 00 00 00 ff 00 00 00 ff 00 00 00 ff ff ff
ff ff 00 00 00 ff ff ff ff ff 00 00 00 ff 00
00 00 00 00 00 00 ff 00 00 00 ff 00 00 00 ff
00 00 00 ff 00 00 00 ff 00 00 00 ff 00 00 00
ff 00 00 00 ff ff ff ff ff 00 00 00 ff ff ff
ff ff ff ff ff ff ff ff ff ff 00 00 00 ff 00
00 00 00 00 00 00 00 00 00 00 ff ff ff ff ff
00 00 00 ff ff ff ff ff 00 00 00 ff ff ff ff
ff 00 00 00 ff ff ff ff ff 00 00 00 ff ff ff
ff ff ff ff ff ff ff ff ff ff 00 00 00 ff 00
00 00 00 00 00 00 00 00 00 00 ff ff ff ff ff
00 00 00 ff 00 00 00 ff 00 00 00 ff 00 00 00
ff 00 00 00 ff 00 00 00 ff 00 00 00 ff ff ff
ff ff ff ff ff ff ff ff ff ff 00 00 00 ff 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 ff
ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
ff ff ff ff ff ff 00 00 00 ff 00 00 00 ff 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 ff ff ff ff ff ff ff ff ff ff ff ff
ff ff ff ff ff ff ff ff ff 00 00 00 ff 00 00
00 ff 00 00 00 ff 00 00 00 ff 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 ff 00 00 00
ff 00 00 00 ff 00 00 00 ff 00 00 00 ff 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 0d 01
00 00 03 00 00 00 01 00 10 00 00 01 01 00 03
00 00 00 01 00 10 00 00 01 02 00 03 00 00 00
04 00 00 04 aa 01 03 00 03 00 00 00 01 00 01
00 00 01 06 00 03 00 00 00 01 00 02 00 00 01
11 00 04 00 00 00 01 00 00 00 08 01 12 00 03
00 00 00 01 00 01 00 00 01 15 00 03 00 00 00
01 00 04 00 00 01 16 00 03 00 00 00 01 00 10
00 00 01 17 00 04 00 00 00 01 00 00 04 00 01
1c 00 03 00 00 00 01 00 01 00 00 01 52 00 03
00 00 00 01 00 02 00 00 01 53 00 03 00 00 00
04 00 00 04 b2 00 00 00 00 00 08 00 08 00 08
00 08 00 01 00 01 00 01 00 01 
]

troll_tiff = troll_tiff.map do |byte|
  byte.to_i(16)
end.pack('C*')

troll_url = <<-URL.delete("\n")
data:image/png;base64,
iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAAACVBMVEUAAAD///8AAABzxoNxAAAAA
3RSTlP//wDXyg1BAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAElJREFUGN
Ntj0EKADEIA2fy/0fvIS2WxUhBh6qR/MQCGCUhOGIDSB8loKCCzYNo+6DgfsGCI+mM4I1ny1lCEsY
GZMDxXetTrNd+jqUBCGff77QAAAAASUVORK5CYII=
URL

pb = Pasteboard.new

item = [
  [Pasteboard::Type::TIFF,     troll_tiff],
  [Pasteboard::Type::URL,      troll_url],
  [Pasteboard::Type::URL_NAME, 'trollface'],
  [Pasteboard::Type::UTF8,      troll_url],
]

pb.put item

system 'open -a "Clipboard Viewer"'
