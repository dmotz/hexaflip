{exec, spawn} = require 'child_process'

output = (data) -> console.log data.toString()

print  = (fn) ->
  (err, stdout, stderr) ->
    throw err if err
    console.log stdout, stderr
    fn?()


task 'build', 'compile and minify library, build demo site assets', ->
  exec 'stylus -u nib hexaflip.styl', print()
  exec 'stylus -u nib demo/demo.styl', print()
  exec 'coffee -mc demo/demo.coffee', print()
  exec 'coffee -mc hexaflip.coffee', print ->
    exec 'uglifyjs -o hexaflip.min.js hexaflip.js', print()


task 'watch', 'compile continuously', ->
  coffee     = spawn 'coffee', ['-mwc', 'hexaflip.coffee']
  stylus     = spawn 'stylus', ['-u', 'nib', '-w', 'hexaflip.styl']
  demoCoffee = spawn 'coffee', ['-mwc', 'demo/demo.coffee']
  demoStylus = spawn 'stylus', ['-u', 'nib', '-w', 'demo/demo.styl']

  for proc in [coffee, stylus, demoCoffee, demoStylus]
    proc.stdout.on 'data', output
    proc.stderr.on 'data', output
