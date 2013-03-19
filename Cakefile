{exec} = require 'child_process'

option '-t', '--type [DIR]', 'full or core'

task 'clean', 'clear workspace', ->
    cmd = '''
        rm -rf build/coala &&
        cd coala &&
        rm *.js 2>/dev/null &&
        find applications/ components/ core/ features/ layouts/ scaffold/ -name "*.js" | xargs rm -f;
    '''

    exec cmd, (err, stdout, stderr) ->
        console.log stdout, stderr
        console.log 'clean done'

task 'compile', 'Compile all client-side CoffeeScript to JavaScript files.', ->
    exec 'coffee -c .', (err, stdout, stderr) ->
        console.log stdout, stderr
        exec 'coffee -b -c coala/require-config.coffee', (e, so, se) ->
            console.log so, se
            console.log 'compile done'

task 'build', 'Build', (options) ->
    build = if options.type is 'core'
        'coala/coala'
    else
        'coala/applications/default'
    build = "r.js -o build.js name=#{build}"

    cmd = """
        cake clean &&
        cake compile &&
        cd build &&
        mkdir -p coala/vendors &&
        cp -R ../coala/themes coala/ &&
        cd coala/themes/default &&
        r.js -o cssIn=main.css out=main-build.css &&
        rm main.css && cleancss -o main.css main-build.css &&
        rm main-build.css && cd - &&
        cp ../coala/vendors/modernizr.js coala/vendors/ &&
        cp ../coala/vendors/html5shiv.js coala/vendors/ &&
        cp ../coala/require-config.js coala/ &&
        cp -R ../coala/vendors/require coala/vendors/ &&
        #{build}
    """

    exec cmd, (err, stdout, stderr) ->
        console.log stdout, stderr
