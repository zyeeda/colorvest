{exec} = require 'child_process'

task 'build', 'Compile all client-side CoffeeScript to JavaScript files.', ->
    exec 'coffee -c .', (err, stdout, stderr) ->
        console.log stdout, stderr
        exec 'coffee -b -c require-config.coffee', (e, so, se) ->
            console.log so, se
