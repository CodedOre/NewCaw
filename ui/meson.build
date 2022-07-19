# Cawbird UI build file

# Compile Blueprint files
blueprints = custom_target(
  'blueprints',
  input: files(
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
