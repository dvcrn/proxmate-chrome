module.exports = function (grunt) {
    grunt.initConfig({
        karma: {
            unit: {
                configFile: 'karma.conf.js',
                singleRun: true,
            }
        }
    });

    // Register tasks.
    grunt.loadNpmTasks('grunt-karma');

    grunt.registerTask('test', 'karma');
    grunt.registerTask('default', 'test');
};