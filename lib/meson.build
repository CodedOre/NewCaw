# Cawbird backend build file

# Backend dependencies
libdepends = [
  dependency('glib-2.0',       version: '>= 2.50'),
  dependency('gtk4',           version: '>= 4.0'),
  dependency('json-glib-1.0',  version: '>= 1.2'),
  dependency('libsoup-3.0',    version: '>= 3.0'),
  dependency('rest-1.0',       version: '>= 0.9'),
  dependency('libsecret-1',    version: '>= 0.20.5')
]

# Add libxml as dependency for Mastodon
if mastodon_backend
  libdepends += dependency('libxml-2.0', version: '>= 2.9.12')
endif

# Base files
libfiles = [
  'Base/Collections/Collection.vala',
  'Base/Collections/CollectionCalls.vala',
  'Base/Collections/CollectionFilters.vala',
  'Base/Collections/CollectionHeaders.vala',
  'Base/Collections/CollectionPins.vala',
  'Base/Collections/FilteredCollection.vala',
  'Base/Collections/PostConnections.vala',
  'Base/Content/Media.vala',
  'Base/Content/MediaEnums.vala',
  'Base/Content/Post.vala',
  'Base/Content/PostAuxiliary.vala',
  'Base/Content/TextModule.vala',
  'Base/Content/User.vala',
  'Base/Content/UserDataField.vala',
  'Base/Content/UserEnums.vala',
  'Base/Organization/HomeTimeline.vala',
  'Base/Organization/Thread.vala',
  'Base/Organization/UserTimeline.vala',
  'Base/System/Client.vala',
  'Base/System/ClientLists.vala',
  'Base/System/ClientState.vala',
  'Base/System/Server.vala',
  'Base/System/Session.vala',
  'Base/System/SessionAuth.vala',
  'Base/Utils/Examples.vala',
  'Base/Utils/KeyStorage.vala',
  'Base/Utils/MediaLoader.vala',
  'Base/Utils/PlatformEnum.vala',
  'Base/Utils/StateIO.vala',
  'Base/Utils/TextFormats.vala',
  'Base/Utils/TextUtils.vala'
]

# Add files for active backends
if mastodon_backend
  libfiles += [
    'Mastodon/Content/Media.vala',
    'Mastodon/Content/Post.vala',
    'Mastodon/Content/User.vala',
    'Mastodon/Content/UserDataField.vala',
    'Mastodon/Organization/HomeTimeline.vala',
    'Mastodon/Organization/Thread.vala',
    'Mastodon/Organization/UserTimeline.vala',
    'Mastodon/System/Server.vala',
    'Mastodon/System/Session.vala',
    'Mastodon/System/SessionAuth.vala',
    'Mastodon/System/SessionCalls.vala',
    'Mastodon/Utils/ParseUtils.vala',
    'Mastodon/Utils/TextParser.vala'
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
