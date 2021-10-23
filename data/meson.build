# Cawbird data build file

# Install Desktop file
desktop_file = i18n.merge_file(
  input: 'uk.co.ibboard.Cawbird.desktop.in',
  output: 'uk.co.ibboard.Cawbird.desktop',
  type: 'desktop',
  po_dir: '../subprojects/po',
  install: true,
  install_dir: join_paths(get_option('datadir'), 'applications')
)

desktop_utils = find_program('desktop-file-validate', required: false)
if desktop_utils.found()
  test('Validate desktop file', desktop_utils,
    args: [desktop_file]
  )
endif

# Install GSettings schema
install_data('uk.co.ibboard.Cawbird.gschema.xml',
  install_dir: join_paths(get_option('datadir'), 'glib-2.0/schemas')
)

compile_schemas = find_program('glib-compile-schemas', required: false)
if compile_schemas.found()
  test('Validate schema file', compile_schemas,
    args: ['--strict', '--dry-run', meson.current_source_dir()]
  )
endif

# Install icons for Cawbird
subdir('icons')
