if get_option('enable-tests')

  test_deps = icd_deps + [ icd ]

  test('router',
    executable('images-test', 'images-test.vala',
      dependencies: test_deps
    )
  )

endif
