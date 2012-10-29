
define [
    'jquery'
    'underscore'
    'zui/coala/util'
    'zui/coala/config'
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
    filePromise = null
    if config.development is true and files is null
        files = {}
        filePromise = $.get(helperPath, root: config.appRoot, (data) ->
            _.extend files, data
        , 'json')

    resourceLoader = (resource, plugin) ->
        deferred = $.Deferred()
        path = if plugin then plugin + '!' + resource else resource
        load = (path) =>
            require [path], (result) ->
                deferred.resolve result

        loadIt = ->
            return load path if not config.development
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
