module.exports = function (grunt) {

    require('load-grunt-tasks')(grunt);

    grunt.initConfig({
        manifest: grunt.file.readJSON('manifest.json'),
        karma: {
            backend: {
                configFile: 'karma.conf.js',
                singleRun: true,
            },
            frontend: {
                configFile: 'karma-frontend.conf.js',
                singleRun: true,
            }
        },
        browserify: {
            src: {
                files: {
                    '.tmp/src/application.module.js': ['.tmp/src/*.js'],
                }
            },
            test: {
                files: {
                    '.tmp/test/test.js': ['.tmp/src/*.js', '.tmp/test/plugin/*.js'],
                }
            },
            dist: {
                files: {
                    'dist/src/application.module.js': ['.build/src/*.js'],
                }
            }
        },
        watch: {
            coffee: {
                files: ['src/**/*.coffee'],
                tasks: ['coffee:src', 'karma']
            },
            test: {
                files: ['test/**/*.coffee'],
                tasks: ['coffee:test', 'karma']
            },
            pages: {
                files: ['pages/**/*'],
                tasks: ['copy:src']
            }
        },
        coffee: {
            src: {
                expand: true,
                src: ['src/**/*.coffee'],
                dest: '.tmp/',
                ext: '.js'
            },
            test: {
                expand: true,
                src: ['test/**/*.coffee'],
                dest: '.tmp/',
                ext: '.js'
            },
            dist: {
                expand: true,
                src: ['src/**/*.coffee'],
                dest: '.build/',
                ext: '.js'
            }
        },
        ngmin: {
            dist: {
                files: [
                    {expand: true, src: ['.build/src/pages/**/*.js'], dest: ''},
                ]
            }
        },
        uglify: {
            dist: {
                options: {
                    mangle: true,
                    compress: true,
                    banner: '/*\n' +
                            '  <%= manifest.name %> version <%= manifest.version %> by David Mohl\n' +
                            '  Built on <%= grunt.template.today("yyyy-mm-dd @ HH:MM") %>\n' +
                            '  Please see github.com/dabido/proxmate-chrome/ for infos\n' +
                            '*/\n'
                },
                files: [{
                    expand: true,
                    src: ['dist/**/*.js', '!dist/bower_components/**'],
                    dest: ''
                }]
            }
        },
        closurecompiler: {
            dist: {
                options: {
                    compilation_level: 'SIMPLE_OPTIMIZATIONS',
                    banner: '/*\n' +
                            '  <%= manifest.name %> version <%= manifest.version %> by David Mohl\n' +
                            '  Built on <%= grunt.template.today("yyyy-mm-dd @ HH:MM") %>\n' +
                            '  Please see github.com/dabido/proxmate-chrome/ for infos\n' +
                            '*/\n'
                },
                files: [{
                    expand: true,
                    src: ['dist/**/*.js', '!dist/bower_components/**'],
                    dest: ''
                }]
            }
        },
        cssmin: {
            dist: {
                files: [{
                    expand: true,
                    src: ['dist/**/*.css'],
                    dest: ''
                }]
            }
        },
        htmlmin: {
            dist: {
                options: {
                    collapseWhitespace: true,
                    collapseBooleanAttributes: true,
                    removeCommentsFromCDATA: true,
                    removeOptionalTags: true
                },
                files: [{
                    expand: true,
                    src: ['dist/**/*.html'],
                    dest: ''
                }]
            }
        },
        copy: {
            src: {
                files: [{
                        '.tmp/proxmate.json': 'proxmate.json',
                        '.tmp/manifest.json': 'manifest.json',
                        '.tmp/background.html': 'background.html',
                        '.tmp/bower_components/jquery/dist/jquery.js': 'bower_components/jquery/dist/jquery.js',
                        '.tmp/bower_components/angular/angular.js': 'bower_components/angular/angular.js',
                        '.tmp/bower_components/angular-route/angular-route.js': 'bower_components/angular-route/angular-route.js',
                        '.tmp/bower_components/angular-mocks/angular-mocks.js': 'bower_components/angular-mocks/angular-mocks.js'
                    },
                    {expand: true, src: ['test/testdata/**'], dest: '.tmp/'},
                    {expand: true, src: ['ressources/**'], dest: '.tmp/'},
                    {expand: true, src: ['pages/**'], dest: '.tmp/'},
                ]
            },
            build: {
                files: [{
                    '.build/proxmate.json': 'proxmate.json',
                    '.build/manifest.json': 'manifest.json',
                }]
            },
            dist: {
                files: [{
                        'dist/manifest.json': 'manifest.json',
                        'dist/background.html': 'background.html',
                        'dist/bower_components/jquery/dist/jquery.js': 'bower_components/jquery/dist/jquery.min.js',
                        'dist/bower_components/angular/angular.js': 'bower_components/angular/angular.min.js',
                        'dist/bower_components/angular-route/angular-route.js': 'bower_components/angular-route/angular-route.min.js',
                    },

                    {expand: true, src: ['ressources/**'], dest: 'dist/'},
                    {expand: true, src: ['pages/**'], dest: 'dist/'},
                    {expand: true, src: ['pages/**', 'page-worker/**'], dest: 'dist/src', cwd: '.build/src'},
                ]
            }
        },
        clean: {
            src: '.tmp',
            dist: 'dist',
            build: '.build'
        }
    });

    // Register commands
    grunt.registerTask('src', [
        'clean:src',
        'coffee:src',
        'coffee:test',
        'copy:src',
        'browserify:src',
        'browserify:test'
    ])

    grunt.registerTask('build', [
        'clean:build',
        'clean:dist',

        'coffee:dist',

        'copy:build',
        'copy:dist',

        'ngmin:dist',
        'browserify:dist',
        'closurecompiler:dist',
        'cssmin:dist',
        'htmlmin:dist',
        'clean:build'
    ])

    grunt.registerTask('serve', ['src', 'watch'])
    grunt.registerTask('test', ['src', 'karma']);
    grunt.registerTask('default', 'test');
};
