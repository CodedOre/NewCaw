# Cawbird backend build file

# Backend dependencies
libdepends = [
  dependency('glib-2.0',       version: '>= 2.50'),
  dependency('gtk4',           version: '>= 4.0'),
  dependency('gdk-pixbuf-2.0', version: '>= 2.0'),
  dependency('json-glib-1.0',  version: '>= 1.2'),
  dependency('libsoup-3.0',    version: '>= 3.0')
]

# Base files
libfiles = [
  'Base/Content/Media.vala',
  'Base/Content/Picture.vala',
  'Base/Content/Post.vala',
  'Base/Content/PostEnums.vala',
  'Base/Content/TextModule.vala',
  'Base/Content/User.vala',
  'Base/Utils/MediaLoader.vala',
  'Base/Utils/TextUtils.vala'
]

# Add files for active backends
if get_option('support_mastodon')
  libfiles += [
    'Mastodon/Content/Media.vala',
    'Mastodon/Content/Picture.vala',
    'Mastodon/Content/Post.vala',
    'Mastodon/Content/User.vala',
    'Mastodon/Utils/TextUtils.vala'
  ]
endif
if get_option('support_twitter')
  libfiles += [
    'Twitter/Content/Media.vala',
    'Twitter/Content/Picture.vala',
    'Twitter/Content/Post.vala',
    'Twitter/Content/User.vala',
    'Twitter/Utils/TextUtils.vala'
  ]
endif
if get_option('support_twitter_legacy')
  libfiles += [
    'TwitterLegacy/Content/Media.vala',
    'TwitterLegacy/Content/Picture.vala',
    'TwitterLegacy/Content/Post.vala',
    'TwitterLegacy/Content/User.vala',
    'TwitterLegacy/Utils/TextUtils.vala'
  ]
endif

backendsrc = include_directories('.')

# Build the library
backendlib = library(
  'cawbird',
  libfiles,
  dependencies:   libdepends,
	vala_vapi:     'libcawbird.vapi',
	install:        true
)
