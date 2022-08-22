# Cawbird backend build file

# Backend dependencies
libdepends = [
  dependency('glib-2.0',       version: '>= 2.50'),
  dependency('gtk4',           version: '>= 4.0'),
  dependency('json-glib-1.0',  version: '>= 1.2'),
  dependency('libsoup-3.0',    version: '>= 3.0'),
  dependency('rest-1.0',       version: '>= 0.9')
]

# Add libxml as dependency for Mastodon
if mastodon_backend
  libdepends += dependency('libxml-2.0', version: '>= 2.9.12')
endif

# Base files
libfiles = [
  'Base/Content/Media.vala',
  'Base/Content/MediaEnums.vala',
  'Base/Content/Post.vala',
  'Base/Content/PostEnums.vala',
  'Base/Content/TextModule.vala',
  'Base/Content/User.vala',
  'Base/Content/UserDataField.vala',
  'Base/Content/UserEnums.vala',
  'Base/Organization/Collection.vala',
  'Base/Organization/PseudoItem.vala',
  'Base/Organization/HomeTimeline.vala',
  'Base/Organization/UserTimeline.vala',
  'Base/System/Account.vala',
  'Base/System/Client.vala',
  'Base/System/Server.vala',
  'Base/Utils/MediaLoader.vala',
  'Base/Utils/TextFormats.vala',
  'Base/Utils/TextUtils.vala'
]

# Add files for active backends
if mastodon_backend
  libfiles += [
    'Mastodon/Content/Media.vala',
    'Mastodon/Content/Post.vala',
    'Mastodon/Content/User.vala',
    'Mastodon/Organization/HomeTimeline.vala',
    'Mastodon/Organization/UserTimeline.vala',
    'Mastodon/System/Account.vala',
    'Mastodon/System/Server.vala',
    'Mastodon/Utils/ParseUtils.vala',
    'Mastodon/Utils/TextParser.vala'
  ]
endif
if twitter_backend
  libfiles += [
    'Twitter/Content/Media.vala',
    'Twitter/Content/Post.vala',
    'Twitter/Content/User.vala',
    'Twitter/Organization/HomeTimeline.vala',
    'Twitter/Organization/UserTimeline.vala',
    'Twitter/System/Account.vala',
    'Twitter/System/Server.vala',
    'Twitter/Utils/ParseUtils.vala',
    'Twitter/Utils/TextUtils.vala'
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
