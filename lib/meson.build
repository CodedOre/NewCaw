# Cawbird backend build file

# Backend dependencies
libdepends = [
  dependency('glib-2.0', version: '>=2.50'),
  dependency('json-glib-1.0')
]

# Base files
libfiles = [
]

# Add files for active backends
if get_option('support_mastodon')
  libfiles += [
  ]
endif
if get_option('support_twitter')
  libfiles += [
  ]
endif
if get_option('support_twitter_legacy')
  libfiles += [
  ]
endif

backendsrc = include_directories('.')

# Build the library
backendlib = library(
  'cawbird',
  libfiles,
  dependencies:   libdepends,
	vala_vapi:     'libcawbird.vapi'
)
