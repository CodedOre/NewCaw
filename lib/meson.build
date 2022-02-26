# Cawbird backend build file

# Backend dependencies
libdepends = [
  dependency('glib-2.0',       version: '>= 2.50'),
  dependency('gtk4',           version: '>= 4.0'),
  dependency('gdk-pixbuf-2.0', version: '>= 2.0'),
  dependency('json-glib-1.0',  version: '>= 1.2'),
  dependency('libsoup-3.0',    version: '>= 3.0'),
  dependency('rest-1.0',       version: '>= 0.9')
]

# Base files
libfiles = [
  'Base/Content/Media.vala',
  'Base/Content/MediaEnums.vala',
  'Base/Content/Post.vala',
  'Base/Content/PostEnums.vala',
  'Base/Content/Profile.vala',
  'Base/Content/TextModule.vala',
  'Base/Content/User.vala',
  'Base/Content/UserDataField.vala',
  'Base/Content/UserEnums.vala',
  'Base/Organization/Account.vala',
  'Base/Organization/Client.vala',
  'Base/Organization/Server.vala',
  'Base/Utils/APICalls.vala',
  'Base/Utils/MediaLoader.vala',
  'Base/Utils/TextFormats.vala',
  'Base/Utils/TextUtils.vala'
]

# Add files for active backends
if get_option('mastodon_backend').enabled()
  libfiles += [
    'Mastodon/Content/Media.vala',
    'Mastodon/Content/Post.vala',
    'Mastodon/Content/Profile.vala',
    'Mastodon/Content/User.vala',
    'Mastodon/Organization/Account.vala',
    'Mastodon/Organization/Server.vala',
    'Mastodon/Utils/TextUtils.vala'
  ]
endif
if get_option('twitter_backend').enabled()
  libfiles += [
    'Twitter/Platform.vala',
    'Twitter/Content/Media.vala',
    'Twitter/Content/Post.vala',
    'Twitter/Content/Profile.vala',
    'Twitter/Content/User.vala',
    'Twitter/Organization/Account.vala',
    'Twitter/Organization/Server.vala',
    'Twitter/Utils/TextUtils.vala'
  ]
endif
if get_option('twitter_legacy_backend').enabled()
  libfiles += [
    'TwitterLegacy/Platform.vala',
    'TwitterLegacy/Content/Media.vala',
    'TwitterLegacy/Content/Post.vala',
    'TwitterLegacy/Content/Profile.vala',
    'TwitterLegacy/Content/User.vala',
    'TwitterLegacy/Organization/Account.vala',
    'TwitterLegacy/Organization/Server.vala',
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
