define [
    'zui/coala/feature'
], (Feature) ->

    type: 'feature'
    name: 'DEFAULT'
    fn: (module, feature, featureName, args) ->
        [container, options] = args
        deferred = $.Deferred()

        if options?.avoidLoadingFeature is true
            deferred.resolve null
            return deferred

        module.loadResource(featureName).done (def) ->
            return deferred.resolve(null) if def is null

            def.baseName = featureName
            def.module = module
            def.container = container if container?

            feature = new Feature def, options

            deferred.resolve feature
        deferred
