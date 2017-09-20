tl_resources = gnome.compile_resources('timelapse-resources',
  'timelapse.gresource.xml',
  c_name: 'timelapse',
)

tl_sources = [
  'app.vala',
  'config.vala',
  'main.vala',
  'model.vala',
  'router.vala',
  'models/camera.vala',
  'models/image.vala',
  'routes/cameras.vala',
  'routes/images.vala',
]

executable('tl', tl_resources + tl_sources,
       install: true,
     vala_args: [ '--pkg', 'libgphoto2' ],
  dependencies: tl_deps,
)
