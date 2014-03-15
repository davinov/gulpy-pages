gulp = require 'gulp'
path = require 'path'
fs = require 'fs'

# Plugins
## Utilities
clean = require 'gulp-clean'
gutil = require 'gulp-util'
changed = require 'gulp-changed'
concat = require 'gulp-concat'
uglify = require 'gulp-uglify'
symlink = require 'gulp-symlink'
serve = require 'gulp-serve'
## Languages
coffee = require 'gulp-coffee'
less = require 'gulp-less'
jade = require 'gulp-jade'
## Bower
bowerFiles = require 'gulp-bower-files'
## Angular
templateCache = require 'gulp-angular-templatecache'

# Paths
PUBLIC_PATH = 'public'
APP_PATH = 'app'
VENDOR_PATH = 'vendor'
ASSETS_PATH = APP_PATH + '/assets'
LESS_MAIN_FILE = APP_PATH + '/style.less'

# Filenames
VENDOR_MAIN_FILE = 'vendor.js'
APP_MAIN_FILE = 'app.js'
TEMPLATES_FILE = 'templates.js'
TEMPLATES_MODULE = 'templates'
CSS_MAIN_FILE = 'style.css'

# Tasks
gulp.task 'build', [
  'assets'
  'compile'
  'minify'
]

gulp.task 'serve', ['assets', 'compile'], serve PUBLIC_PATH

gulp.task 'watch', ['build'], ->
  gulp.watch APP_PATH+'/**/*.coffee', ['coffee']
  gulp.watch APP_PATH+'/**/*.jade', ['templates']
  gulp.watch APP_PATH+'/**/*.less', ['less']
  gulp.watch APP_PATH+'/*.jade', ['jade']
  gulp.watch ASSETS_PATH, ['assets']
  gulp.watch 'bower_components', ['vendor']
  gulp.watch VENDOR_PATH, ['vendor']
  serve(PUBLIC_PATH)()

# Subtasks
gulp.task 'compile', [
  'vendor'
  'coffee'
  'less'
  'jade'
  'templates'
]

gulp.task 'bower', (done) ->
  bowerFiles()
  .pipe changed VENDOR_PATH
  .pipe symlink VENDOR_PATH
  .on 'error', gutil.log
  .on 'end', done
  return

gulp.task 'vendor', ['bower'], (done) ->
  gulp.src VENDOR_PATH + '/**/*.js'
  .pipe changed PUBLIC_PATH
  .pipe concat VENDOR_MAIN_FILE
  .pipe gulp.dest PUBLIC_PATH + '/js'
  .on 'error', gutil.log
  .on 'end', done
  return

gulp.task 'coffee', (done) ->
  gulp.src APP_PATH + '/**/*.coffee'
  .pipe changed PUBLIC_PATH
  .pipe coffee bare: true
  .pipe concat APP_MAIN_FILE
  .pipe gulp.dest PUBLIC_PATH + '/js'
  .on 'error', gutil.log
  .on 'end', done
  return

gulp.task 'less', (done) ->
  gulp.src LESS_MAIN_FILE
  .pipe changed PUBLIC_PATH
  .pipe less
      paths: [ path.join __dirname ]
  .pipe gulp.dest PUBLIC_PATH + '/css'
  .on 'error', gutil.log
  .on 'end', done
  return

gulp.task 'jade', (done) ->
  gulp.src APP_PATH + '/*.jade'
  .pipe changed PUBLIC_PATH
  .pipe jade
      pretty: true
  .pipe gulp.dest PUBLIC_PATH
  .on 'error', gutil.log
  .on 'end', done
  return

gulp.task 'templates', (done) ->
  gulp.src APP_PATH + '/*/**/*.jade'
  .pipe changed PUBLIC_PATH
  .pipe jade doctype: 'html'
  .pipe templateCache
      filename: TEMPLATES_FILE
      module: TEMPLATES_MODULE
      standalone: true
  .pipe gulp.dest PUBLIC_PATH + '/js'
  .pipe gulp.dest PUBLIC_PATH
  .on 'error', gutil.log
  .on 'end', done
  return

gulp.task 'assets', (done) ->
  gulp.src ASSETS_PATH + '/**'
  .pipe gulp.dest PUBLIC_PATH
  .on 'error', gutil.log
  .on 'end', done
  return

gulp.task 'minify', ['vendor', 'coffee'], (done) ->
  gulp.src PUBLIC_PATH + '/**/*.js'
  .pipe changed PUBLIC_PATH
  .pipe uglify outSourceMap: true
  .pipe gulp.dest PUBLIC_PATH
  .on 'error', gutil.log
  .on 'end', done
  return

gulp.task 'clean', (done) ->
  gulp.src PUBLIC_PATH, read: false
  .pipe clean()
  .on 'error', gutil.log
  .on 'end', done
  return
