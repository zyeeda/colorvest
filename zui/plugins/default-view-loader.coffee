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

        if options?.avoidLoadingView is true
            def =
                baseName: viewName
                module: module
                feature: feature
            def.avoidLoadingHandlers = true if options.avoidLoadingHandlers is true

            deferred.resolve new View def
            return deferred

        module.loadResource(getPath(feature, 'view', viewName)).done (def = {}) ->

            def.baseName = viewName
            def.module = module
            def.feature = feature

            view = new View def
            deferred.resolve view
        deferred
