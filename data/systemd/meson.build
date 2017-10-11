serviceconf = configuration_data()
serviceconf.set('bindir', join_paths(get_option('prefix'), get_option('bindir')))
serviceconf.set('datadir', pkg_datadir)
serviceconf.set('sysconfdir', pkg_sysconfdir)

configure_file(
          input: 'timelapse.service.in',
         output: 'timelapse.service',
  configuration: serviceconf,
        install: true,
    install_dir: join_paths(get_option('sysconfdir'), 'systemd', 'system'),
)
