define [
    'cdeio/core/feature'
    'cdeio/core/resource-loader'
    'cdeio/core/config'
], (Feature, loadResource, config) ->

    type: 'feature'
    name: 'cdeio'
    fn: (module, feature, featureName, args) ->
        options = args[0]
        deferred = $.Deferred()

        cdeio = module.getApplication().findModule('cdeio-features')
        if not cdeio
            cdeio = module.getApplication().module('cdeio-features')
            cdeio.paths = ['cdeio/features']
            cdeio.initRouters()

        cdeio.loadResource(featureName + '.feature/' + config.featureFileName).done (def) ->
            return deferred.resolve(null) if def is null

            def.baseName = featureName
            def.module = cdeio

            feature = new Feature def, options

            deferred.resolve feature
        deferred
