raml2html = find_program('raml2html', required: false)
if raml2html.found()
  configure_file(
            input: 'icd.raml',
           output: 'icd.html',
          command: [ raml2html, '--input', '@INPUT@', '--validate', '--pretty', '--output', '@OUTPUT@' ],
      install_dir: join_paths(pkg_datadir, 'doc'),
  )
endif
