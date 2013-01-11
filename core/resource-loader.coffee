
define [
    'jquery'
    'underscore'
    'coala/core/util'
    'coala/core/config'
], ($, _, util, config) ->
    {log, error} = util

    # handle 'timeout' error
    defaultHandler = require.onError

    require.onError = (err) ->
        if err.requireType is 'timeout'
            log baseName: 'NOTFOUND', "timeout when load modules:#{err.requireModules}"
            for name in err.requireModules.split ' '
                require.s.contexts._.completeLoad name
        else
            defaultHandler.call require, err

    helperPath = config.helperPath or ''
    files = null
    filePromise = $.Deferred()
    if config.noBackend is true
        filePromise.resolve()
        require.s.contexts._.config.urlArgs = if config.development then '_c=' + (new Date()).getTime() else ''
    else
        $.get(helperPath + '/development', (data) ->
            config.development = if data is 'false' then false else true
            if config.development is true and files is null
                files = {}
                $.get(helperPath, root: config.appRoot, (data) ->
                    _.extend files, data
                    filePromise.resolve()
                , 'json')
            else
                filePromise.resolve()
            require.s.contexts._.config.urlArgs = if config.development then '_c=' + (new Date()).getTime() else ''
        )

    resourceLoader = (resource, plugin) ->
        deferred = $.Deferred()
        path = if plugin then plugin + '!' + resource else resource
        load = (path) =>
            require [path], (result) ->
                deferred.resolve result

        loadIt = ->
            return load path if config.noBackend is true or not config.development
            if resource.substring(0, config.appRoot.length) is config.appRoot
                idx = resource.lastIndexOf '/'
                folder = config.scriptRoot + '/' + (resource.substring 0, idx + 1)
                filename = resource.substring (idx + 1)
                if not files[folder] or not files[folder][filename]
                    deferred.resolve null
                else
                    load path
            else
                load path

        log baseName: 'resource loader', 'load path:', path
        $.when(filePromise).then ->
            loadIt()

        deferred.promise()
    resourceLoader
