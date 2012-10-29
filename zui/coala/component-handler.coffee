define [
    'underscore'
    'zui/coala/resource-loader'
    'zui/coala/util'
], (_, loadResource, util) ->
    {error} = util

    ComponentHandler =
        initializers: []
        handlers: {}
        promises: []
        register: (name, initializer, handler) ->
            initializer = _.bind (path)->
                @promises.push loadResource path
            , @, initializer if _.isString initializer

            @initializers.push initializer
            @handlers[name] = handler
            @
        initialize: ->
            promises = []
            promises.push initializer() for initializer in @initializers
            @deferred = $.when.apply($, @promises)
        done: (fn) ->
            @initialize() if not @deferred
            @deferred.done fn
        defaultHandler: (name, $el, options, view) ->
            error view, 'no component handler for component type:' + name if not $el[name]
            $el[name] options
        handle: (name, $el, options = {}, view) ->
            handler = @handlers[name]
            if handler then handler($el, options, view) else @defaultHandler(name, $el, options, view)
    ComponentHandler
