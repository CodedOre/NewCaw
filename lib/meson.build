# Cawbird backend build file

# Backend dependencies
libdepends = [
  dependency('glib-2.0', version: '>=2.50'),
  dependency('json-glib-1.0')
]

# Base files
libfiles = [
  'Base/Content/Post.vala',
  'Base/Content/TextModule.vala',
  'Base/Utils/TextUtils.vala'
]

# Add files for active backends
if get_option('support_mastodon')
  libfiles += [
    'Mastodon/Content/Post.vala',
    'Mastodon/Utils/TextUtils.vala'
  ]
endif
if get_option('support_twitter')
  libfiles += [
    'Twitter/Content/Post.vala',
    'Twitter/Utils/TextUtils.vala'
  ]
endif
if get_option('support_twitter_legacy')
  libfiles += [
    'TwitterLegacy/Content/Post.vala',
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
