{exec} = require 'child_process'

task 'build', 'Compile all client-side CoffeeScript to JavaScript files.', ->
    exec 'coffee -c zui', (err, stdout, stderr) ->
        console.log stdout + stderr
