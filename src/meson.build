# Cawbird client build file

# Dependencies for the client
cawdepends = [
  dependency('gio-2.0',       version: '>= 2.50'),
  dependency('glib-2.0',      version: '>= 2.7.1'),
  dependency('gtk4',          version: '>= 4.7'),
  dependency('libadwaita-1',  version: '>= 1.2'),
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
  'MainWindow.vala',
  'Authentication/AuthView.vala',
  'Authentication/BrowserPage.vala',
  'Authentication/CodePage.vala',
  'Authentication/FinalPage.vala',
  'Authentication/LoadPage.vala',
  'Authentication/ServerPage.vala',
  'Authentication/StartPage.vala',
  'Content/CollectionFilter.vala',
  'Content/CollectionView.vala',
  'Content/PostActions.vala',
  'Content/PostItem.vala',
  'Content/PostMetrics.vala',
  'Content/PostStatus.vala',
  'Content/UserCard.vala',
  'Content/UserDisplay.vala',
  'Media/MediaDialog.vala',
  'Media/MediaDisplay.vala',
  'Media/MediaDisplayItem.vala',
  'Media/MediaPreview.vala',
  'Media/MediaSelector.vala',
  'Pages/MainPage.vala',
  'Pages/ThreadPage.vala',
  'Pages/UserPage.vala',
  'Preferences/AccountSettings.vala',
  'Preferences/AccountsPage.vala',
  'Preferences/AppearancesPage.vala',
  'Preferences/PreferencesWindow.vala',
  'Utils/DisplayUtils.vala',
  'Utils/SystemInfo.vala',
  'Widgets/BadgesBox.vala',
  'Widgets/FilterButton.vala',
  'Widgets/CroppedPicture.vala',
  'Widgets/SessionRow.vala',
  'Widgets/SessionSidebar.vala',
  'Widgets/UserAvatar.vala',
  'Widgets/UserButton.vala',
  'Widgets/WaitingButton.vala'
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
