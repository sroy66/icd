configure_file(
          input: 'icd.service.in',
         output: 'icd.service',
  configuration: subst,
        install: true,
    install_dir: join_paths(get_option('sysconfdir'), 'systemd', 'system'),
)
