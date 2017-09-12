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

dep_glib = dependency('glib-2.0')
dep_gobject = dependency('gobject-2.0')
dep_gio = dependency('gio-2.0')
dep_soup = dependency('libsoup-2.4')
dep_vsgi = subproject('valum').get_variable('vsgi')
dep_valum = subproject('valum').get_variable('valum')

tl_deps = [
  dep_glib,
  dep_gobject,
  dep_gio,
  dep_soup,
  dep_vsgi,
  dep_valum,
]

subdir('data')
subdir('src')

message('\n  '.join(status))
