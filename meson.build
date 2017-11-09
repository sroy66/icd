project('icd', [ 'c', 'vala' ],
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
  'Image Capture Service @0@'.format(meson.project_version()),
  '', '',
]

# Warning message
if (version_split[1].to_int() % 2 == 1)
  status += [
    'You are building a debug version of icd. There may be more bugs in',
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
  ['-I' + join_paths(meson.current_source_dir(), 'vapi')],
], language: 'c')

add_project_arguments([
  ['--vapidir', join_paths(meson.current_source_dir(), 'vapi')],
  ['--pkg', 'libgphoto2'],
  ['--pkg', 'libgda-5.0'],
  ['--pkg', 'libgtop-2.0'],
  ['--pkg', 'gudev-1.0'],
], language: 'vala')

dep_glib = dependency('glib-2.0')
dep_gobject = dependency('gobject-2.0')
dep_gio = dependency('gio-2.0')
dep_gda = dependency('libgda-5.0')
dep_gee = dependency('gee-0.8')
dep_gphoto = dependency('libgphoto2')
dep_gtop = dependency('libgtop-2.0')
dep_gudev = dependency ('gudev-1.0')
dep_json = dependency('json-glib-1.0')
dep_soup = dependency('libsoup-2.4')
dep_tmpl = dependency('template-glib-1.0')
dep_xml = dependency('libxml-2.0')
dep_posix = meson.get_compiler('vala').find_library('posix')

dep_valum = dependency('valum-0.3', version: '>= 0.3.13', required: false)
if not dep_valum.found()
  message('Valum needs to be installed for the installation to work')
  dep_valum = subproject('valum').get_variable('valum')
endif

dep_vsgi = dependency('vsgi-0.3', version: '>= 0.3.13', required: false)
if not dep_vsgi.found()
  dep_vsgi = subproject('valum').get_variable('vsgi')
endif

# using template-glib as a subproject failed
#libtemplate_glib = subproject('template-glib',
#  default_options: [
#    'package_subdir=' + meson.project_name()
#  ]
#)
#dep_tmpl = libtemplate_glib.get_variable('libtemplate_glib_dep')

icd_deps = [
  dep_glib,
  dep_gobject,
  dep_gio,
  dep_gda,
  dep_gee,
  dep_gphoto,
  dep_gtop,
  dep_gudev,
  dep_json,
  dep_soup,
  dep_tmpl,
  dep_xml,
  dep_posix,
  dep_valum,
  dep_vsgi,
]

# Substitutions for various .in files
subst = configuration_data()

# Installation paths
pkg_datadir = join_paths(get_option('prefix'), get_option('datadir'), meson.project_name())
pkg_sysconfdir = join_paths(get_option('sysconfdir'), meson.project_name())

# XXX Could only think of this for controlling template loading
if get_option('buildtype') == 'debug'
  pkg_templatedir = join_paths(meson.build_root(), 'data', 'templates')
else
  pkg_templatedir = join_paths(pkg_datadir, 'templates')
endif

subst.set('bindir', join_paths(get_option('prefix'), get_option('bindir')))
subst.set('datadir', pkg_datadir)
subst.set('sysconfdir', pkg_sysconfdir)
subst.set('templatedir', pkg_templatedir)

# Create config.h
conf = configuration_data()

conf.set_quoted('PACKAGE_NAME', meson.project_name())
conf.set_quoted('PACKAGE_VERSION', meson.project_version())
conf.set_quoted('PACKAGE_STRING', '@0@-@1@'.format(meson.project_name(), meson.project_version()))
conf.set_quoted('PACKAGE_URL', 'https://github.com/geoffjay/icd')

conf.set_quoted('DATADIR', pkg_datadir)
conf.set_quoted('SYSCONFDIR', pkg_sysconfdir)
conf.set_quoted('TEMPLATEDIR', pkg_templatedir)

# For i18n
conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())

# Write config.h
configure_file(
         output: 'config.h',
  configuration: conf,
)

# Enable other sections to find config.h
extra_includes = [
  include_directories('.'),
]

gnome = import('gnome')

subdir('src')
subdir('data')
subdir('doc')
subdir('tests')

if get_option('enable-systemd')
  meson.add_install_script('build-aux/meson/meson-post-install.sh')
endif

message('\n'.join(status))
