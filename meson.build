project(
  'Cawbird',
  ['vala', 'c'],
  version:        '1.9.0',
  meson_version:  '>= 0.56.0',
)

# Load meson modules
i18n  = import('i18n')
gnome = import('gnome')

# Set build configuration
if get_option('buildtype') == 'debug' or get_option('buildtype') == 'debugoptimized'
  add_project_arguments('-D', 'DEBUG', language: 'vala')
endif

# Configure supported platforms
if get_option('support_mastodon')
  add_project_arguments('-D', 'SUPPORT_MASTODON', language: 'vala')
endif
if get_option('support_twitter')
  add_project_arguments('-D', 'SUPPORT_TWITTER', language: 'vala')
endif
if get_option('support_twitter_legacy')
  add_project_arguments('-D', 'SUPPORT_TWITTER_LEGACY', language: 'vala')
endif

# Set up translation domain
add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()), language:'c')

# Build and test the backend from subdirectories
subdir('lib')
subdir('tests')

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
  'src/config.vapi',
  'src/Cawbird.vala',
  'src/Content/DetailedPost.vala'
]

# Compile program resources
cawfiles += gnome.compile_resources(
  'cawbird_resources',
  'cawbird.gresource.xml',
  c_name: 'cawbird'
)

# Add build configurations
cdata = configuration_data()
cdata.set_quoted ('LOCALEDIR', join_paths(get_option('prefix'), get_option('localedir')))
cdata.set_quoted ('GETTEXT_PACKAGE', meson.project_name())
configure_file(
  output: 'config.h',
  configuration: cdata
)

# Build the program
executable(
  'cawbird',
  cawfiles,
  dependencies:  cawdepends,
  vala_args:    '--target-glib=2.50',
  install:       true
)

# Add the translations
subdir('po')
