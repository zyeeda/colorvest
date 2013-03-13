{exec} = require 'child_process'

option '-t', '--type [DIR]', 'full or core'

task 'compile', 'Compile all client-side CoffeeScript to JavaScript files.', ->
    exec 'coffee -c .', (err, stdout, stderr) ->
        console.log stdout, stderr
        exec 'coffee -b -c require-config.coffee', (e, so, se) ->
            console.log so, se

task 'build', 'Build', (options) ->
    build = if options.type is 'full'
        'coala/applications/default'
    else
        'coala/coala'
    build = "r.js -o build.js name=#{build}"

    cmd = """
        cd build &&
        rm -rf coala &&
        mkdir -p coala/vendors &&
        cp -R ../coala/themes coala/ &&
        cp ../coala/vendors/modernizr.js coala/vendors/ &&
        cp ../coala/vendors/html5shiv.js coala/vendors/ &&
        cp ../coala/require-config.js coala/ &&
        cp -R ../coala/vendors/require coala/vendors/ &&
        #{build}
    """

    exec cmd, (err, stdout, stderr) ->
        console.log stdout, stderr
