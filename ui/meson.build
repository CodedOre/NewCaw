# Cawbird UI build file

# Compile Blueprint files
blueprints = custom_target(
  'blueprints',
  input: files(
    'Authentication/AuthView.blp',
    'Authentication/BrowserPage.blp',
    'Authentication/CodePage.blp',
    'Authentication/FinalPage.blp',
    'Authentication/LoadPage.blp',
    'Authentication/ServerPage.blp',
    'Authentication/StartPage.blp',
    'Content/CollectionList.blp',
    'Content/PostActions.blp',
    'Content/PostItem.blp',
    'Content/PostMetrics.blp',
    'Content/PostStatus.blp',
    'Content/UserCard.blp',
    'Content/UserDisplay.blp',
    'Media/MediaDisplay.blp',
    'Media/MediaDisplayItem.blp',
    'Media/MediaPreviewItem.blp',
    'Pages/UserPage.blp',
    'Widgets/BadgesBox.blp',
    'Widgets/FilterButton.blp',
    'Widgets/UserAvatar.blp',
    'Widgets/UserButton.blp',
    'Widgets/WaitingButton.blp',
    'Windows/MainWindow.blp',
    'Windows/MediaDialog.blp'
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
