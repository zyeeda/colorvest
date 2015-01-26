define [
    'cdeio/core/feature'
    'cdeio/core/resource-loader'
    'cdeio/core/config'
], (Feature, loadResource, config) ->

# 不存在 cdeio 则创建 cdeio，然后加载对应 feature
# cdeio 是一个 application
# 与 default-feature-loader 不同的是 此 loader 所加载的 feature 路径为 /cdeio/features/**.feature/feature,
# default-feature-loader 加载的根路径为 /app/**
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
