var gulp       = require('gulp');
var browserify = require('gulp-browserify');
var sass       = require('gulp-sass');
var concat     = require('gulp-concat');
var uglify     = require('gulp-uglify');
var minifycss  = require("gulp-minify-css");
var imagemin   = require('gulp-imagemin');
var sourcemaps = require('gulp-sourcemaps');
var gzip       = require('gulp-gzip');
var clean      = require('gulp-clean');
var coffeex    = require('gulp-coffee-react');

var config = {
    distFolder: 'dist',
    distName: 'colorvest.all',
    scripts: ['modules/colorvest.coffee'],
    styles: ['assets/main.scss'], 
    images: 'assets'
};

gulp.task('clean', function() {
    gulp.src(config.distFolder + '/**/*.js', {read: false})
    .pipe(clean());
});

gulp.task('images', function() {
    return gulp.src(config.images)
        .pipe(imagemin({
            optimizationLevel: 5
        }))
        .pipe(gulp.dest(config.distFolder + '/img'));
});

gulp.task('scripts', function() {
    gulp.src(config.scripts,  { read: false })
    .pipe(browserify({
        // insertGlobals : true,
        // debug : !gulp.env.production,
        exclude: ['jquery', 'lodash', 'bootstrap', 'react', 'flux'],
        transform: ['coffee-reactify'],
        extensions: ['.coffee']
    }))
    // .pipe(sourcemaps.init())
    .pipe(concat(config.distName + '.js'))
    .pipe(uglify())
    // .pipe(gzip())
    // .pipe(sourcemaps.write())
    .pipe(gulp.dest(config.distFolder))
});

gulp.task('styles', function() {
    return gulp.src(config.styles)
        .pipe(sass())
        .pipe(concat(config.distName + '.css'))
        // .pipe(minifycss())
        // .pipe(gzip())
        .pipe(gulp.dest(config.modules));
});

gulp.task('watch', function() {
    gulp.watch(config.scripts, ['scripts']);
    // gulp.watch(config.styles, ['styles']);
});

gulp.task('build', function() {
    return gulp.src('modules/**/*.coffee')
        .pipe(coffeex({ bare: true }))
        .pipe(gulp.dest(config.distFolder));
});

// The default task (called when you run `gulp` from cli)
gulp.task('default', ['clean', 'scripts', 'build']);
