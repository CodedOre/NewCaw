# Cawbird UI build file

# Compile Blueprint files
blueprints = custom_target(
  'blueprints',
  input: files(
    'MainWindow.blp',
    'Authentication/AuthView.blp',
    'Authentication/BrowserPage.blp',
    'Authentication/CodePage.blp',
    'Authentication/FinalPage.blp',
    'Authentication/LoadPage.blp',
    'Authentication/ServerPage.blp',
    'Authentication/StartPage.blp',
    'Collections/CollectionFilter.blp',
    'Collections/CollectionView.blp',
    'Content/PostActions.blp',
    'Content/PostContent.blp',
    'Content/PostItem.blp',
    'Content/PostMetrics.blp',
    'Content/PostStatus.blp',
    'Content/UserCard.blp',
    'Content/UserDataDisplay.blp',
    'Content/UserDisplay.blp',
    'Media/MediaDialog.blp',
    'Media/MediaDisplay.blp',
    'Media/MediaDisplayItem.blp',
    'Media/MediaSelector.blp',
    'Pages/MainPage.blp',
    'Pages/ThreadPage.blp',
    'Pages/UserPage.blp',
    'Preferences/AppearancesPage.blp',
    'Preferences/PreferencesWindow.blp',
    'Preferences/SessionSettings.blp',
    'Preferences/SessionsPage.blp',
    'Widgets/BadgesBox.blp',
    'Widgets/FilterButton.blp',
    'Widgets/SessionRow.blp',
    'Widgets/SessionSidebar.blp',
    'Widgets/UserAvatar.blp',
    'Widgets/UserButton.blp',
    'Widgets/WaitingButton.blp'
  ),
  output: '.',
  command: [find_program('blueprint-compiler'), 'batch-compile', '@OUTPUT@', '@CURRENT_SOURCE_DIR@', '@INPUT@'],
)

# Install UI resources
cawresources += gnome.compile_resources(
  'cawbird_ui_resources',
  'interface.gresource.xml',
  dependencies: blueprints,
  c_name: 'cawbird_ui'
)
