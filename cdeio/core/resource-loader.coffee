define [
    'jquery'
    'underscore'
    'cdeio/core/util'
    'cdeio/core/config'
], ($, _, util, config) ->
    {log, error} = util

    helperPath = config.helperPath or ''
    if config.noBackend is true
        require.s.contexts._.config.urlArgs = if config.development then '_c=' + (new Date()).getTime() else ''
    else
        $.get helperPath + '/development', (data) ->
            config.development = if data is 'false' then false else true
            require.s.contexts._.config.urlArgs = if config.development then '_c=' + (new Date()).getTime() else ''

    (resource, plugin) ->
        deferred = $.Deferred()
        path = if plugin then plugin + '!' + resource else resource

        load = (path) =>
            require [path], (result) ->
                deferred.resolve result
            , (err) ->
                failedId = err.requireModules && err.requireModules[0]
                if failedId is path
                    require.undef path
                    define path, null
                    require [path], ->
                    deferred.resolve null
                else
                    deferred.reject null
                    throw err

        log baseName: 'resource-loader', 'load resource: ', path
        load path

        deferred.promise()
