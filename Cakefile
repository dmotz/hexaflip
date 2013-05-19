{exec, spawn} = require 'child_process'
nibArg = '--include /usr/local/share/npm/lib/node_modules/nib/lib/'

output = (data) -> console.log data.toString()

print = (fn) ->
  (err, stdout, stderr) ->
    throw err if err
    console.log stdout, stderr
    fn?()


task 'build', 'compile and minify library, build demo site assets', ->
  exec "stylus #{ nibArg } hexaflip.styl", print()
  exec "stylus #{ nibArg } ./demo/demo.styl -o ./demo", print()
  exec 'coffee -c ./demo/demo.coffee', print()
  exec 'coffee -mc hexaflip.coffee', print ->
    exec 'uglifyjs -o hexaflip.min.js hexaflip.js', print()


task 'watch', 'compile continuously', ->
  coffee = spawn 'coffee', ['-mwc', 'hexaflip.coffee']
  coffee.stdout.on 'data', output
  coffee.stderr.on 'data', output
  stylus = spawn 'stylus', ["#{ nibArg } -w", 'hexaflip.styl']
  stylus.stdout.on 'data', output
  stylus.stderr.on 'data', output
