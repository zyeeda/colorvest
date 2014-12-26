var gulp       = require('gulp');
var clean      = require('gulp-clean');
var coffeex    = require('gulp-coffee-react');

var config = {
    distFolder: 'dist',
    modulesFiles: 'modules/**/*.coffee'
};

gulp.task('clean', function() {
    gulp.src(config.distFolder + '/**/*.js', {read: false})
    .pipe(clean());
});

gulp.task('watch', function() {
    gulp.watch(config.modulesFiles, ['build']);
});

gulp.task('build', function() {
    return gulp.src(config.modulesFiles)
        .pipe(coffeex({ bare: true }))
        .pipe(gulp.dest(config.distFolder));
});

gulp.task('default', ['clean', 'build']);
