define [
    'zui/coala/view'
    'zui/coala/config'
], (View, config) ->
    {getPath} = config

    type: 'view'
    name: 'DEFAULT'
    fn: (module, feature, viewName, args) ->
        deferred = $.Deferred()
        options = args[0]

        module.loadResource(getPath(feature, 'view', viewName)).done (def = {}) ->

            def.baseName = viewName
            def.module = module
            def.feature = feature

            view = new View def
            deferred.resolve view
        deferred
