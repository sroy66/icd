subdir('config')

icd_resources = gnome.compile_resources('icd-resources',
  'icd.gresource.xml',
  c_name: 'icd',
)

icd_vala_args = [
  '--vapidir', dir_libconfig,
  '--pkg', 'icd-config',
]

icd_sources = [
  'config.vala',
  'database.vala',
  'model.vala',
  'router.vala',
  'models/camera.vala',
  'models/image.vala',
  'routes/cameras.vala',
  'routes/images.vala',
]

icd_app_sources = [
  'app.vala',
  'main.vala',
]

icd_deps += link_libconfig

icd_lib = library(meson.project_name(), icd_sources,
  dependencies: icd_deps,
   vala_header: 'icd.h',
     vala_args: icd_vala_args,
       install: false,
)

executable(meson.project_name(), icd_resources + icd_sources + icd_app_sources,
  dependencies: icd_deps,
     vala_args: icd_vala_args,
       install: true,
)

icd = declare_dependency(
  include_directories: include_directories('.'),
            link_with: icd_lib,
)
