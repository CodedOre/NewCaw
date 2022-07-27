# Cawbird data build file

# Add an "Development Version" on debug builds
desktop_name = meson.project_name ()
if dev_build
  desktop_name += ' (Development Version)'
endif

# Configure application informations
application_info = configuration_data()
application_info.set('app_id',   application_id)
application_info.set('app_name', desktop_name)

# Configure Desktop file
desktop_file_config = configure_file(
          input: 'uk.co.ibboard.Cawbird.desktop',
         output: '@0@.desktop.in'.format(application_id),
  configuration: application_info
)

# Install translated Desktop file
desktop_file = i18n.merge_file(
        input: desktop_file_config,
       output: ('@0@.desktop').format(application_id),
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

# Configure Appstream file
appstream_file_config = configure_file(
          input: 'uk.co.ibboard.Cawbird.appdata.xml',
         output: '@0@.appdata.xml.in'.format(application_id),
  configuration: application_info
)

# Install translated Appstream file
appstream_file = i18n.merge_file(
        input: appstream_file_config,
       output: ('@0@.appdata.xml').format(application_id),
       po_dir: '../subprojects/po',
      install: true,
  install_dir: join_paths(get_option('datadir'), 'metainfo')
)

appstream_util = find_program('appstream-util', required: false)
if appstream_util.found()
  test('Validate appstream file', appstream_util,
    args: ['validate', appstream_file]
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
