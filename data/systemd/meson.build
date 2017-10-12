configure_file(
          input: 'timelapse.service.in',
         output: 'timelapse.service',
  configuration: subst,
        install: true,
    install_dir: join_paths(get_option('sysconfdir'), 'systemd', 'system'),
)
