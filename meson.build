project(
  'Cawbird',
  ['vala', 'c'],
  version:        '1.9.0',
  meson_version:  '>= 0.56.0',
)

# Project arguments
if get_option('buildtype') == 'debug' or get_option('buildtype') == 'debugoptimized'
  add_project_arguments('-D', 'DEBUG', language: 'vala')
endif

if get_option('support_mastodon')
  add_project_arguments('-D', 'SUPPORT_MASTODON', language: 'vala')
endif
if get_option('support_twitter')
  add_project_arguments('-D', 'SUPPORT_TWITTER', language: 'vala')
endif
if get_option('support_twitter_legacy')
  add_project_arguments('-D', 'SUPPORT_TWITTER_LEGACY', language: 'vala')
endif

# Build and test the backend from subdirectories
subdir('lib')
subdir('tests')

# Load meson modules
i18n  = import('i18n')
gnome = import('gnome')

# Dependencies for the client
cawdepends = [
  dependency('gio-2.0',       version: '>= 2.50'),
  dependency('glib-2.0',      version: '>= 2.50'),
  dependency('gtk4',          version: '>= 4.0'),
  dependency('libadwaita-1',  version: '>= 1.0')
]

cawdepends += declare_dependency(
  link_with:            backendlib,
  include_directories:  backendsrc,
  dependencies:         libdepends
)

# Sources of the client
cawfiles = [
  'src/Cawbird.vala',
  'src/Content/DetailedPost.vala'
]

cawfiles += gnome.compile_resources(
  'cawbird_resources',
  'cawbird.gresource.xml',
  c_name: 'cawbird'
)

# Build the program
executable(
  'cawbird',
  cawfiles,
  dependencies:  cawdepends,
  vala_args:    '--target-glib=2.50',
  install:       true
)
