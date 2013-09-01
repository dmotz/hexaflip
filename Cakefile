{exec, spawn} = require 'child_process'

print = (fn) ->
  (err, stdout, stderr) ->
    throw err if err
    console.log stdout, stderr
    fn?()


startWatcher = (bin, args) ->
  watcher = spawn bin, args?.split ' '
  watcher.stdout.pipe process.stdout
  watcher.stderr.pipe process.stderr


task 'build', 'compile and minify library, build demo site assets', ->
  exec 'stylus -u nib hexaflip.styl', print()
  exec 'stylus -u nib demo/demo.styl', print()
  exec 'coffee -mc demo/demo.coffee', print()
  exec 'coffee -mc hexaflip.coffee', print ->
    exec 'uglifyjs -o hexaflip.min.js hexaflip.js', print()


task 'watch', 'compile continuously', ->
  startWatcher.apply @, pair for pair in [
    ['coffee', '-mwc hexaflip.coffee']
    ['stylus', '-u nib -w hexaflip.styl']
    ['coffee', '-mwc demo/demo.coffee']
    ['stylus', '-u nib -w demo/demo.styl']
  ]
