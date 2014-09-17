define [
    'cdeio/core/feature'
    'cdeio/core/config'
], (Feature, config) ->

    type: 'feature'
    name: 'DEFAULT'
    fn: (module, feature, featureName, args) ->
        options = args[0]
        deferred = $.Deferred()

        if options?.avoidLoadingFeature is true
            deferred.resolve null
            return deferred

        module.loadResource(featureName + '.feature/' + config.featureFileName).done (def) ->
            return deferred.resolve null if def is null

            def.baseName = featureName
            def.module = module

            feature = new Feature def, options

            deferred.resolve feature

        deferred.promise()
