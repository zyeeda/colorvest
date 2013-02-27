define [
    'coala/core/feature'
    'coala/core/resource-loader'
], (Feature, loadResource) ->

    type: 'feature'
    name: 'coala'
    fn: (module, feature, featureName, args) ->
        options = args[0]
        deferred = $.Deferred()

        coala = module.getApplication().findModule('coala-features')
        if not coala
            coala = module.getApplication().module('coala-features')
            coala.paths = ['coala/features']
            coala.initRouters()

        coala.loadResource(featureName).done (def) ->
            return deferred.resolve(null) if def is null

            def.baseName = featureName
            def.module = coala

            feature = new Feature def, options

            deferred.resolve feature
        deferred
