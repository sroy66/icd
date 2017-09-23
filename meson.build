project('time-lapse', [ 'c', 'vala' ],
          license: 'GPL3+',
          version: '0.1.0',
    meson_version: '>= 0.40.1',
  default_options: [
                     'c_std=gnu11',
                     'warning_level=2',
                   ],
)

version_split = meson.project_version().split('.')
MAJOR_VERSION = version_split[0]
MINOR_VERSION = version_split[1]
MICRO_VERSION = version_split[2]

status = [
  '', '',
  'Time Lapse Microservice @0@'.format(meson.project_version()),
  '', '',
]

# Warning message
if (version_split[1].to_int() % 2 == 1)
  status += [
    'You are building a debug version of FSM. There may be more bugs in',
    'this version that you are comfortable with.',
    '', ''
  ]
endif

status += [
  'Version ............................... : @0@'.format(meson.project_version()),
  'Build Type ............................ : @0@'.format(get_option('buildtype')),
  '',
  'Prefix ................................ : @0@'.format(get_option('prefix')),
  'Libdir ................................ : @0@'.format(join_paths(get_option('prefix'), get_option('libdir'))),
  '', ''
]

add_project_arguments([
  ['-I' + join_paths(meson.current_source_dir(), 'vapi')]
], language: 'c')

add_project_arguments([
  ['--vapidir', join_paths(meson.current_source_dir(), 'vapi')],
  ['--pkg', 'libgphoto2'],
  ['--pkg', 'libgda-5.0'],
], language: 'vala')

dep_glib = dependency('glib-2.0')
dep_gobject = dependency('gobject-2.0')
dep_gio = dependency('gio-2.0')
dep_gee = dependency('gee-0.8')
dep_gda = dependency('libgda-5.0')
dep_soup = dependency('libsoup-2.4')
dep_tmpl = dependency('template-glib-1.0')
dep_xml = dependency('libxml-2.0')
dep_vsgi = subproject('valum').get_variable('vsgi')
dep_valum = subproject('valum').get_variable('valum')
dep_posix = meson.get_compiler('vala').find_library('posix')

#lib_gphoto = meson.get_compiler('c').find_library('libgphoto2')
#vapi_gphoto = meson.get_compiler('vala').find_library('libgphoto2', dirs: join_paths(meson.current_source_dir(), 'vapi'))
#dep_gphoto = declare_dependency(dependecies: [lib_gphoto, vapi_gphoto])

dep_gphoto = dependency('libgphoto2')

# using template-glib as a subproject failed
#libtemplate_glib = subproject('template-glib',
#  default_options: [
#    'package_subdir=' + meson.project_name()
#  ]
#)
#dep_tmpl = libtemplate_glib.get_variable('libtemplate_glib_dep')

tl_deps = [
  dep_glib,
  dep_gobject,
  dep_gio,
  dep_gee,
  dep_gda,
  dep_soup,
  dep_tmpl,
  dep_xml,
  dep_vsgi,
  dep_valum,
  dep_posix,
  dep_gphoto,
]

gnome = import('gnome')

subdir('data')
subdir('src')
subdir('tests')

message('\n  '.join(status))
