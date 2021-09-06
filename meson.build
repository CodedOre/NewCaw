project(
  'Cawbird',
  ['c', 'vala'],
  version:        '1.9.0',
  meson_version:  '>= 0.50.0',
)

i18n  = import('i18n')
gnome = import('gnome')

cawdepends = [
  dependency('gio-2.0', version: '>= 2.50'),
  dependency('gtk4', version: '>= 4.0'),
  dependency('libadwaita-1', version: '>= 1.0')
]

cawfiles = [
  'src/main.vala'
]

cawfiles += gnome.compile_resources(
  'cawbird_resources',
  'cawbird.gresource.xml',
  c_name: 'cawbird'
)

executable(
  'cawbird',
  cawfiles,
  dependencies:  cawdepends,
  vala_args:    '--target-glib=2.50',
  install:       true
)
