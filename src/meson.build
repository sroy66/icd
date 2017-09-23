tl_resources = gnome.compile_resources('timelapse-resources',
  'timelapse.gresource.xml',
  c_name: 'timelapse',
)

tl_sources = [
  'config.vala',
  'database.vala',
  'model.vala',
  'router.vala',
  'models/camera.vala',
  'models/image.vala',
  'routes/cameras.vala',
  'routes/images.vala',
]

tl_app_sources = [
  'app.vala',
  'main.vala',
]

tl_lib = library('tl', tl_sources,
  dependencies: tl_deps,
   vala_header: 'tl.h',
       install: false,
)

executable('tl', tl_resources + tl_sources + tl_app_sources,
       install: true,
  dependencies: tl_deps,
)

tl = declare_dependency(include_directories: include_directories('.'),
  link_with: tl_lib,
)
