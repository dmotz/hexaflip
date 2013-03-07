{exec, spawn} = require 'child_process'
nibArg = '--include /usr/local/share/npm/lib/node_modules/nib/lib/'

output = (data) -> console.log data.toString()

print = (fn) ->
  (err, stdout, stderr) ->
    throw err if err
    console.log stdout, stderr
    fn?()


task 'build', 'Build and minify HexaFlip', ->
  exec "stylus #{ nibArg } hexaflip.styl", print()
  exec 'coffee -c hexaflip.coffee', print ->
    exec 'uglifyjs -o hexaflip.min.js hexaflip.js', print()


task 'watch', 'Build HexaFlip continuously', ->
  coffee = spawn 'coffee', ['-wc', 'hexaflip.coffee']
  coffee.stdout.on 'data', output
  coffee.stderr.on 'data', output
  stylus = spawn 'stylus', ["#{ nibArg } -w", 'hexaflip.styl']
  stylus.stdout.on 'data', output
  stylus.stderr.on 'data', output
