# Cawbird client build file

# Dependencies for the client
cawdepends = [
  dependency('gio-2.0',       version: '>= 2.50'),
  dependency('glib-2.0',      version: '>= 2.7.1'),
  dependency('gtk4',          version: '>= 4.0'),
  dependency('libadwaita-1',  version: '>= 1.2'),
  dependency('libsecret-1',   version: '>= 0.20.5'),
  # Compile with GLib Math support.
  meson.get_compiler('c').find_library('m', required: false)
]

# Link backend to client
cawdepends += declare_dependency(
  link_with:            backendlib,
  include_directories:  backendsrc,
  dependencies:         libdepends
)

# Sources of the client
cawsources = cawresources
cawsources += [
  'config.vapi',
  'Cawbird.vala',
  'Content/CollectionList.vala',
  'Content/PostDisplay.vala',
  'Content/UserCard.vala',
  'Content/UserDisplay.vala',
  'Content/UserView.vala',
  'Media/MediaDisplay.vala',
  'Media/MediaDisplayItem.vala',
  'Media/MediaPreview.vala',
  'Media/MediaPreviewItem.vala',
  'System/Authentication/AuthView.vala',
  'System/Authentication/BrowserPage.vala',
  'System/Authentication/CodePage.vala',
  'System/Authentication/FinalPage.vala',
  'System/Authentication/LoadPage.vala',
  'System/Authentication/ServerPage.vala',
  'System/Authentication/StartPage.vala',
  'System/Utils/KeyStorage.vala',
  'System/Utils/PlatformEnum.vala',
  'System/Utils/Session.vala',
  'Utils/DisplayUtils.vala',
  'Widgets/BadgesBox.vala',
  'Widgets/FilterButton.vala',
  'Widgets/CroppedPicture.vala',
  'Widgets/UserAvatar.vala',
  'Widgets/WaitingButton.vala',
  'Windows/MainWindow.vala',
  'Windows/MediaDialog.vala'
]

# Add build configurations
cdata = configuration_data()
cdata.set_quoted ('PROJECT_NAME',      meson.project_name())
cdata.set_quoted ('PROJECT_VERSION',   version)
cdata.set_quoted ('APPLICATION_ID',    application_id)
cdata.set_quoted ('LOCALEDIR',         join_paths(get_option('prefix'), get_option('localedir')))
cdata.set_quoted ('TWITTER_OAUTH_KEY', get_option ('twitter_oauth_key'))
configure_file(
  output: 'config.h',
  configuration: cdata
)

# Build the client
executable(
  'cawbird',
  cawsources,
  dependencies:  cawdepends,
  vala_args: [
    '--target-glib=2.50',
    '--gresourcesdir=ui/'
  ],
  install:       true
)
