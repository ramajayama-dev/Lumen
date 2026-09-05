project(
    'lumen',
    'c',
    version: '0.1.0',
    default_options: [
        'c_std=c11',
        'warning_level=3',
    ],
)

lumen_inc = include_directories('include')

executable(
    'lumen',
    [
        'src/main.c',
        'src/compositor/compositor.c',
    ],
    include_directories: lumen_inc,
    install: true,
)
