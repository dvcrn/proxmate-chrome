module.exports = function (grunt) {
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
        coffee: {
            src: {
                expand: true,
                flatten: true,
                cwd: 'src/coffee',
                src: ['*.coffee'],
                dest: 'src/js/',
                ext: '.js'
            },
            test: {
                expand: true,
                flatten: true,
                cwd: 'test/coffee',
                src: ['*.coffee'],
                dest: 'test/js/',
                ext: '.js'
            }
        },
        uglify: {
            compress: {
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
                    cwd: 'src/js',
                    src: '**/*.js',
                    dest: 'dist/src/js'
                }]
            },
            vendors: {
                options: {
                    mangle: true,
                    compress: true
                },
                files: {
                    'dist/bower_components/jquery/jquery.js': 'bower_components/jquery/jquery.js',
                    'dist/bower_components/requirejs/require.js': 'bower_components/requirejs/require.js',
                    'dist/bower_components/requirejs-text/text.js': 'bower_components/requirejs-text/text.js',
                }
            }
        },
        copy: {
            main: {
                files: {
                    'dist/manifest.json': 'manifest.json',
                    'dist/proxmate.json': 'proxmate.json',
                    'dist/background.html': 'background.html',
                }
            },
            ressources: {
                files: [
                    {expand: true, src: ['ressources/**'], dest: 'dist/'},
                ]
            }
        },
        clean: ['dist']
    });

    // Register tasks.
    grunt.loadNpmTasks('grunt-karma');
    grunt.loadNpmTasks('grunt-contrib-coffee');
    grunt.loadNpmTasks('grunt-contrib-uglify');
    grunt.loadNpmTasks('grunt-contrib-copy');
    grunt.loadNpmTasks('grunt-contrib-clean');

    // Register commands
    grunt.registerTask('test', 'karma');
    grunt.registerTask('build', ['clean', 'coffee', 'karma', 'copy:main', 'copy:ressources', 'uglify:compress', 'uglify:vendors'])

    grunt.registerTask('default', 'test');
};