define [
    'cdeio/core/feature'
    'cdeio/core/config'
], (Feature, config) ->

    # 对 module.loadResource 方法的包装
    type: 'feature'
    name: 'DEFAULT'
    # args 定义为 args... 可能更好，与 loadPluginManager.invoke 方法中调用的方式一致。
    fn: (module, feature, featureName, args) ->
        # options 即 application.startFeature(featurePath, options) 中的 options
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
