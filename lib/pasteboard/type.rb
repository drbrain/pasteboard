# coding: utf-8

##
# Documentation here comes from the OS X 10.6 Core Library's Uniform Type
# Identifiers Reference.

module Pasteboard::Type

  encoding = defined?(Encoding)

  if encoding then
    ##
    # Maps a type to its encoding.  The default encoding is Encoding::BINARY.

    Encodings = {}

    Encodings.default = Encoding::BINARY
  end

  # :section: System-defined uniform type identifiers

  # Base type for the physical hierarchy.

  ITEM = 'public.item'

  # Base type for all document content.

  CONTENT = 'public.content'

  # Base type for mixed content. For example, a PDF file contains both text
  # and special formatting data.

  COMPOSITE_CONTENT = 'public.composite-content'

  # Base physical type for byte streams (flat files, pasteboard data, and so
  # on).

  DATA = 'public.data'

  # Base functional type for databases.

  DATABASE = 'public.database'

  # Base functional type for scheduled events.

  CALENDAR_EVENT = 'public.calendar-event'

  # Base type for messages (email, IM, and so on).

  MESSAGE = 'public.message'

  # ,public.composite-content,Base type for presentations.

  PRESENTATION = 'public.presentation'

  # Base type for contact information.

  CONTACT = 'public.contact'

  # Base type for an archive of files and directories.

  ARCHIVE = 'public.archive'

  # Base type for items mountable as a volume.

  DISK_IMAGE = 'public.disk-image'

  # Base type for all text, including text with markup information (HTML, RTF,
  # and so on).

  TEXT = 'public.text'

  # Text of unspecified encoding, with no markup. Equivalent to the MIME type
  # text/plain

  PLAIN_TEXT = 'public.plain-text'
  Encodings[TEXT] = Encoding::US_ASCII if encoding

  # Unicode-8

  PLAIN_TEXT_UTF8 = 'public.utf8-plain-text'
  UTF8 = PLAIN_TEXT_UTF8
  Encodings[PLAIN_TEXT_UTF8] = Encoding::UTF_8 if encoding

  # Unicode-16 with byte-order mark (BOM), or if BOM is not present, an
  # external representation byte order (big-endian).

  PLAIN_TEXT_UTF16_EXTERNAL = 'public.utf16-external-plain-text'
  Encodings[PLAIN_TEXT_UTF16_EXTERNAL] = Encoding::UTF_16BE if encoding

  # Unicode-16, native byte order, with an optional byte-order mark (BOM).

  PLAIN_TEXT_UTF16 = 'public.utf16-plain-text'
  Encodings[PLAIN_TEXT_UTF16] = Encoding::UTF_16LE if encoding

  # Classic Mac OS text.

  PLAIN_TEXT_TRADITIONAL = 'com.apple.traditional-mac-plain-text'
  Encodings[PLAIN_TEXT_TRADITIONAL] = Encoding::MacRoman if encoding

  # Rich Text.

  RTF = 'public.rtf'

  # Opaque InkText data.

  INKTEXT = 'com.apple.ink.inktext'

  # HTML text.

  HTML = 'public.html'

  # XML text.

  XML = 'public.xml'

  # Generic source code.

  SOURCE_CODE = 'public.source-code'

  # C source code.

  C_SOURCE = 'public.c-source'

  # Objective-C source code.

  OBJC_SOURCE = 'public.objective-c-source'

  # C++ source code.

  C_PLUS_PLUS_SOURCE = 'public.c-plus-plus-source'
  CXX_SOURCE = C_PLUS_PLUS_SOURCE

  # Objective-C++ source code.

  OBJC_PLUS_PLUS_SOURCE = 'public.objective-c-plus-plus-source'
  OBJCXX_SOURCE = OBJC_PLUS_PLUS_SOURCE

  # C header file.

  C_HEADER = 'public.c-header'

  # C++ header file.

  C_PLUS_PLUS_HEADER = 'public.c-plus-plus-header'
  CXX_HEADER = C_PLUS_PLUS_HEADER

  # Java source code

  JAVA_SOURCE = 'com.sun.java-source'

  # Base type for scripting language source code.

  SCRIPT = 'public.script'

  # Assembly language source code.

  ASSEMBLY_SOURCE = 'public.assembly-source'

  # Rez source code.

  REZ_SOURCE = 'com.apple.rez-source'

  # Mig definition source code.

  MIG_SOURCE = 'public.mig-source'

  # Symbol export list.

  SYMBOL_EXPORT_LIST = 'com.apple.symbol-export'

  # JavaScript.

  JAVASCRIPT_SOURCE = 'com.netscape.javascript-source'

  # Shell script.

  SHELL_SCRIPT = 'public.shell-script'

  # C-shell script.

  CSH_SCRIPT = 'public.csh-script'

  # Perl script.

  PERL_SCRIPT = 'public.perl-script'

  # Python script.

  PYTHON_SCRIPT = 'public.python-script'

  # Ruby script.

  RUBY_SCRIPT = 'public.ruby-script'

  # PHP script.

  PHP_SCRIPT = 'public.php-script'

  # Java web start.

  JAVA_WEB_START = 'com.sun.java-web-start'

  # AppleScript text.

  APPLESCRIPT_TEXT = 'com.apple.applescript.text'

  # AppleScript.

  APPLESCRIPT_SCRIPT = 'com.apple.applescript.script'

  # Object code.

  OBJECT_CODE = 'public.object-code'

  # Mach-O binary.

  MACH_O_BINARY = 'com.apple.mach-o-binary'

  # PEF (CFM-based) binary

  PEF_BINARY = 'com.apple.pef-binary'

  # Microsoft Windows application.

  WINDOWS_EXECUTABLE = 'com.microsoft.windows-executable'

  # Microsoft dynamic link library.

  WINDOWS_DLL = 'com.microsoft.windows-dynamic-link-library'

  # Java class.

  JAVA_CLASS = 'com.sun.java-class'

  # Java archive.

  JAVA_ARCHIVE = 'com.sun.java-archive'

  # Quartz Composer composition.

  QUARTZ_COMPOSER_COMPOSITION = 'com.apple.quartz-composer-composition'

  # GNU archive.

  GNU_TAR_ARCHIVE = 'org.gnu.gnu-tar-archive'

  # Tar archive.

  TAR_ARCHIVE = 'public.tar-archive'

  # Gzip archive.

  GUN_ZIP_ARCHIVE = 'org.gnu.gnu-zip-archive'

  # Gzip tar archive.

  GNU_ZIP_TAR_ARCHIVE = 'org.gnu.gnu-zip-tar-archive'

  # BinHex archive.

  BINHEX_ARCHIVE = 'com.apple.binhex-archive'

  # MacBinary archive.

  MACBINARY_ARCHIVE = 'com.apple.macbinary-archive'

  # Uniform Resource Locator.

  URL = 'public.url'
  Encodings[URL] = Encoding::US_ASCII if encoding

  # File URL.

  FILE_URL = 'public.file-url'
  Encodings[FILE_URL] = Encoding::US_ASCII if encoding

  # URL name.

  URL_NAME = 'public.url-name'
  Encodings[URL_NAME] = Encoding::UTF_8 if encoding

  # vCard (electronic business card).

  VCARD = 'public.vcard'

  # Base type for images.

  IMAGE = 'public.image'

  # Base type for fax images.

  FAX = 'public.fax'

  # JPEG image.

  JPEG = 'public.jpeg'

  # JPEG 2000 image.

  JPEG_2000 = 'public.jpeg-2000'

  # TIFF image.

  TIFF = 'public.tiff'

  # Base type for digital camera raw image formats.

  CAMERA_RAW_IMAGE = 'public.camera-raw-image'

  # PICT image

  PICT = 'com.apple.pict'

  # MacPaint image.

  MACPAINT = 'com.apple.macpaint-image'

  # PNG image

  PNG = 'public.png'

  # X bitmap image.

  XBITMAP = 'public.xbitmap-image'

  # QuickTime image.

  QUICKTIME_IMAGE = 'com.apple.quicktime-image'

  # Mac OS icon image.

  ICNS = 'com.apple.icns'

  # MLTE (Textension) format for mixed text and multimedia data.

  TEXT_MULTIMEDIA_DATA = 'com.apple.txn.text-multimedia-data'

  # Base type for any audiovisual content.

  AUDIOVISUAL_CONTENT = 'public.audiovisual-content'
  AV_CONTENT = AUDIOVISUAL_CONTENT

  # Base type for movies (video with optional audio or other tracks).

  MOVIE = 'public.movie'

  # Base type for video (no audio).

  VIDEO = 'public.video'

  # QuickTime movie.

  QUICKTIME_MOVIE = 'com.apple.quicktime-movie'

  # AVI movie.

  AVI = 'public.avi'

  # MPEG-1 or MPEG-2 content.

  MPEG = 'public.mpeg'

  # MPEG-4 content.

  MPEG4 = 'public.mpeg-4'

  # 3GPP movie.

  MOVIE_3GPP = 'public.3gpp'

  # 3GPP2 movie.

  MOVIE_3GPP2 = 'public.3gpp2'

  # Base type for audio (no video).

  AUDIO = 'public.audio'

  # MPEG-3 audio.

  MP3 = 'public.mp3'

  # MPEG-4 audio.

  MPEG4_AUDIO = 'public.mpeg-4-audio'

  # Protected MPEG-4 audio. (iTunes music store format)

  MPEG4_AUDIO_PROTECTED = 'com.apple.protected-mpeg-4-audio'

  # μLaw audio.

  ULAW = 'public.ulaw-audio'

  # AIFF-C audio.

  AIFC = 'public.aifc-audio'

  # AIFF audio.

  AIFF = 'public.aiff-audio'

  # Core Audio format.

  COREAUDIO = 'com.apple.coreaudio-format'

  # Base type for directories.

  DIRECTORY = 'public.directory'

  # A plain folder (that is, not a package).

  FOLDER = 'public.folder'

  # A volume.

  VOLUME = 'public.volume'

  # A package (that is, a directory presented to the user as a file).

  PACKAGE = 'com.apple.package'

  # A directory with an internal structure specified by Core Foundation Bundle
  # Services. .

  BUNDLE = 'com.apple.bundle'

  # Base type for executable data.

  EXECUTABLE = 'public.executable'

  # Base type for applications and other launchable files.

  APPLICATION = 'com.apple.application'

  # Application bundle.

  APPLICATION_BUNDLE = 'com.apple.application-bundle'

  # Application file.

  APPLICATION_FILE = 'com.apple.application-file'

  # Deprecated application file.

  APPLICATION_FILE_DEPRECATED = 'com.apple.deprecated-application-file'

  # Plugin.

  PLUGIN = 'com.apple.plugin'

  # Spotlight importer plugin.

  METADATA_IMPORTER = 'com.apple.metadata-importer'

  # Dashboard widget.

  DASHBOARD_WIDGET = 'com.apple.dashboard-widget'

  # CPIO archive.

  CPIO_ARCHIVE = 'public.cpio-archive'

  # Zip archive.

  ZIP_ARCHIVE = 'com.pkware.zip-archive'

  # Web Kit webarchive format.

  WEBARCHIVE = 'com.apple.webarchive'

  # Framework.

  FRAMEWORK = 'com.apple.framework'

  # Rich Text Format Directory. That is, Rich Text with content embedding,
  # on-disk format.

  RTFD = 'com.apple.rtfd'

  # Rich Text with content embedding, pasteboard format.

  RTFD_FLAT = 'com.apple.flat-rtfd'

  # Items that the Alias Manager can resolve.

  RESOLVEABLE = 'com.apple.resolvable'

  # UNIX-style symlink.

  SYMLINK = 'public.symlink'

  # A volume mount point

  MOUNT_POINT = 'com.apple.mount-point'

  # Alias record.

  ALIAS_RECORD = 'com.apple.alias-record'

  # Alias file.

  ALIAS_FILE = 'com.apple.alias-file'

  # Base type for fonts.

  FONT = 'public.font'

  # TrueType font.

  TRUETYPE_FONT = 'public.truetype-font'

  # PostScript font.

  POSTSCRIPT_FONT = 'com.adobe.postscript-font'

  # TrueType data fork font.

  TRUETYPE_DATA_FORK_FONT = 'com.apple.truetype-datafork-suitcase-font'

  # PostScript OpenType font.

  OPENTYPE_FONT = 'public.opentype-font'

  # TrueType OpenType font.

  TRUETYPE_TTF_FONT = 'public.truetype-ttf-font'

  # TrueType collection font.

  TRUETYPE_COLLECTION_FONT = 'public.truetype-collection-font'

  # Font suitcase.

  FONT_SUITCASE = 'com.apple.font-suitcase'

  # PostScript Type 1 outline font.

  POSTSCRIPT_LWFN_FONT = 'com.adobe.postscript-lwfn-font'

  # PostScriptType1 outline font.

  POSTSCRIPT_PFB_FONT = 'com.adobe.postscript-pfb-font'

  # PostScriptType 1 outline font.

  POSTSCRIPT_PFA_FONT = 'com.adobe.postscript.pfa-font'

  # ColorSync profile.

  COLORSYNC_PROFILE = 'com.apple.colorsync-profile'

  # :section: Uniform type identifiers for alternate tags

  # Filename extension.

  FILENAME_EXTENSION = 'public.filename-extension'

  # MIME type.

  MIME_TYPE = 'public.mime-type'

  # Four-character code (type OSType).

  OS_TYPE = 'com.apple.ostype'

  # NSPasteboard type.

  PASTEBOARD_TYPE = 'com.apple.nspboard-type'

  # :section: Imported uniform type identifiers

  # PDF data.

  PDF = "com.adobe.pdf (kUTTypePDF)"

  # PostScript data.

  POSTSCRIPT = "com.adobe.postscript"

  # Encapsulated PostScript.

  ENCAPSULATED_POSTSCRIPT = "com.adobe.encapsulated-postscript"

  # Adobe Photoshop document.

  PHOTOSHOP_IMAGE = "com.adobe.photoshop-image"

  # Adobe Illustrator document.

  ILLUSTRATOR_IMAGE = "com.adobe.illustrator.ai-image"

  # GIF image.

  GIF = "com.compuserve.gif (kUTTypeGIF)"

  # Windows bitmap image.

  WINDOWS_BITMAP = "com.microsoft.bmp (kUTTypeBMP)"

  # Windows icon image.

  WINDOWS_ICON = "com.microsoft.ico (kUTTypeICO)"

  # Microsoft Word data.

  WORD_DOCUMENT = "com.microsoft.word.doc"

  # Microsoft Excel data.

  EXCEL_SPREADSHEET = "com.microsoft.excel.xls"

  # Microsoft PowerPoint presentation.

  POWERPOINT_PRESENTATION = "com.microsoft.powerpoint.ppt"

  # Waveform audio.

  MICROSOFT_WAV = "com.microsoft.waveform-audio"

  # Microsoft Advanced Systems format.

  MICROSOFT_ADVANCED_SYSTEMS_FORMAT = "com.microsoft.advanced-systems-format"

  # Windows media.

  WINDOWS_MEDIA_WM = "com.microsoft.windows-media-wm"

  # Windows media.

  WINDOWS_MEDIA_WMV = "com.microsoft.windows-media-wmv"

  # Windows media.

  WINDOWS_MEDIA_WMP = "com.microsoft.windows-media-wmp"

  # Windows media audio.

  WINDOWS_MEDIA_WMA = "com.microsoft.windows-media-wma"

  # Advanced Stream Redirector.

  MICROSOFT_ADVANCED_STREAM_REDIRECTOR =
    "com.microsoft.advanced-stream-redirector"

  # Windows media.

  WINDOWS_MEDIA_WMX = "com.microsoft.windows-media-wmx"

  # Windows media.

  WINDOWS_MEDIA_WVX = "com.microsoft.windows-media-wvx"

  # Windows media audio.

  WINDOWS_MEDIA_WAX = "com.microsoft.windows-media-wax"

  # Apple Keynote document.

  KEYNOTE_DOCUMENT = "com.apple.keynote.key"

  # Apple Keynote theme.

  KEYNOTE_THEME = "com.apple.keynote.kth"

  # TGA image.

  TGA_IMAGE = "com.truevision.tga-image"

  # Silicon Graphics image.

  SGI_IMAGE = "com.sgi.sgi-image"

  # OpenEXR image.

  OPENEXR_IMAGE = "com.ilm.openexr-image"

  # FlashPix image.

  FLASHPIX_IMAGE = "com.kodak.flashpix.image"

  # J2 fax.

  J2_FAX = "com.j2.jfx-fax"

  # eFax fax.

  EFAX_FAX = "com.js.efx-fax"

  # Digidesign Sound Designer II audio.

  SOUND_DESIGNER_II_AUDIO = "com.digidesign.sd2-audio"
  SOUND_DESIGNER_2_AUDIO = SOUND_DESIGNER_II_AUDIO

  # RealMedia.

  REAL_MEDIA = "com.real.realmedia"

  # RealMedia audio.

  REAL_AUDIO = "com.real.realaudio"

  # Real synchronized multimedia integration language.

  REAL_SMIL = "com.real.smil"

  # Stuffit archive.

  STUFFIT_ARCHIVE = "com.allume.stuffit-archive"

end

