tl_resources = gnome.compile_resources('timelapse-resources',
  'timelapse.gresources.xml',
  c_name: 'timelapse',
)

tl_sources = [
  'tl-app.vala',
  'tl-config.vala',
  'tl-main.vala',
  'tl-router.vala',
]

executable('tl', tl_resources + tl_sources,
       install: true,
  dependencies: tl_deps,
)
