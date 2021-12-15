# Cawbird client build file

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
  'config.vapi',
  'Cawbird.vala',
  'MainWindow.vala',
  'Content/PostDisplay.vala',
  'Content/ProfileCard.vala',
  'Content/ProfileDisplay.vala',
  'Media/MediaDisplay.vala',
  'Media/MediaDisplayItem.vala',
  'Media/MediaPreview.vala',
  'Media/MediaPreviewItem.vala',
  'Utils/DisplayUtils.vala',
  'Widgets/BadgesBox.vala',
  'Widgets/CroppedPicture.vala',
  'Widgets/UserAvatar.vala'
]

# Add build configurations
cdata = configuration_data()
cdata.set_quoted ('LOCALEDIR', join_paths(get_option('prefix'), get_option('localedir')))
cdata.set_quoted ('GETTEXT_PACKAGE', meson.project_name())
cdata.set_quoted ('PROJECT_VERSION', version)
configure_file(
  output: 'config.h',
  configuration: cdata
)

# Build the client
executable(
  'cawbird',
  [ cawfiles, cawresources ],
  dependencies:  cawdepends,
  vala_args:    '--target-glib=2.50',
  install:       true
)
