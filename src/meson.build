# Cawbird client build file

# Dependencies for the client
cawdepends = [
  dependency('gio-2.0',       version: '>= 2.50'),
  dependency('glib-2.0',      version: '>= 2.50'),
  dependency('gtk4',          version: '>= 4.0'),
  dependency('libadwaita-1',  version: '>= 1.0'),
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
cawfiles = [
  'config.vapi',
  'Cawbird.vala',
  'MainWindow.vala',
  'Content/PostDisplay.vala',
  'Content/UserCard.vala',
  'Content/UserDisplay.vala',
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
  'System/Utils/AccountManager.vala',
  'System/Utils/KeyStorage.vala',
  'System/Utils/PlatformEnum.vala',
  'Utils/DisplayUtils.vala',
  'Widgets/BadgesBox.vala',
  'Widgets/CroppedPicture.vala',
  'Widgets/UserAvatar.vala',
  'Widgets/WaitingButton.vala'
]

# Add build configurations
cdata = configuration_data()
cdata.set_quoted ('PROJECT_NAME',           meson.project_name())
cdata.set_quoted ('PROJECT_VERSION',        version)
cdata.set_quoted ('LOCALEDIR',              join_paths(get_option('prefix'), get_option('localedir')))
cdata.set_quoted ('TWITTER_OAUTH_1_KEY',    get_option ('twitter_oauth1_tokens')[0])
cdata.set_quoted ('TWITTER_OAUTH_1_SECRET', get_option ('twitter_oauth1_tokens')[1])
cdata.set_quoted ('TWITTER_OAUTH_2_KEY',    get_option ('twitter_oauth2_tokens')[0])
cdata.set_quoted ('TWITTER_OAUTH_2_SECRET', get_option ('twitter_oauth2_tokens')[1])
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
