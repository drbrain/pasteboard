require 'mkmf'

framework_path = '/System/Library/Frameworks/ApplicationServices.framework/Frameworks/HIServices.framework'

$INCFLAGS << " -I #{File.join framework_path, 'Headers'}" 
$LDFLAGS  << " -framework ApplicationServices"

abort unless have_header 'Pasteboard.h'

create_makefile 'pasteboard/pasteboard'

