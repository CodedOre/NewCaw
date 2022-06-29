# Cawbird Icons build file

# Install application icon
scalable_dir = join_paths('scalable', 'apps')
install_data(
  join_paths(scalable_dir, ('@0@.svg').format(application_id)),
  install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', scalable_dir)
)

# Install symbolic app icon
symbolic_dir = join_paths('symbolic', 'apps')
install_data(
  join_paths(symbolic_dir, ('@0@-symbolic.svg').format(application_id)),
  install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', symbolic_dir)
)

# Install UI icons to resources
cawresources += gnome.compile_resources(
  'cawbird_icon_resources',
  'icons.gresource.xml',
  c_name: 'cawbird_icons'
)
