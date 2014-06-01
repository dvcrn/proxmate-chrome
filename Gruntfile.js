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
                    '.tmp/src/module.js': ['.tmp/src/*.js'],
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
                dest: 'dist/',
                ext: '.js'
            }
        },
        ngmin: {
            dist: {
                files: [
                    {expand: true, src: ['dist/src/pages/**/*.js'], dest: ''},
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
                        '.tmp/manifest.json': 'manifest.json',
                        '.tmp/proxmate.json': 'proxmate.json',
                        '.tmp/background.html': 'background.html',
                        '.tmp/bower_components/jquery/dist/jquery.js': 'bower_components/jquery/dist/jquery.js',
                        '.tmp/bower_components/angular/angular.js': 'bower_components/angular/angular.js',
                        '.tmp/bower_components/angular-route/angular-route.js': 'bower_components/angular-route/angular-route.js',
                        '.tmp/bower_components/requirejs/require.js': 'bower_components/requirejs/require.js',
                        '.tmp/bower_components/requirejs-text/text.js': 'bower_components/requirejs-text/text.js',

                        '.tmp/bower_components/angular-mocks/angular-mocks.js': 'bower_components/angular-mocks/angular-mocks.js'
                    },
                    {expand: true, src: ['test/testdata/**'], dest: '.tmp/'},
                    {expand: true, src: ['ressources/**'], dest: '.tmp/'},
                    {expand: true, src: ['pages/**'], dest: '.tmp/'}
                ]
            },
            dist: {
                files: [{
                        'dist/manifest.json': 'manifest.json',
                        'dist/proxmate.json': 'proxmate.json',
                        'dist/background.html': 'background.html',
                        'dist/bower_components/jquery/dist/jquery.js': 'bower_components/jquery/dist/jquery.min.js',
                        'dist/bower_components/angular/angular.js': 'bower_components/angular/angular.min.js',
                        'dist/bower_components/angular-route/angular-route.js': 'bower_components/angular-route/angular-route.min.js',
                        'dist/bower_components/requirejs/require.js': 'bower_components/requirejs/require.js',
                        'dist/bower_components/requirejs-text/text.js': 'bower_components/requirejs-text/text.js'
                    },
                    {expand: true, src: ['ressources/**'], dest: 'dist/'},
                    {expand: true, src: ['pages/**'], dest: 'dist/'}
                ]
            }
        },
        clean: {
            src: '.tmp',
            dist: 'dist'
        }
    });

    // Register commands
    grunt.registerTask('src', [
        'clean:src',
        'coffee:src',
        'coffee:test',
        'copy:src',
        'browserify:src'
    ])

    grunt.registerTask('build', [
        'clean:dist',
        'coffee:dist',
        'copy:dist',
        'ngmin:dist',
        'closurecompiler:dist',
        'cssmin:dist',
        'htmlmin:dist'
    ])

    grunt.registerTask('serve', ['src', 'watch'])
    grunt.registerTask('test', ['src', 'karma']);
    grunt.registerTask('default', 'test');
};
