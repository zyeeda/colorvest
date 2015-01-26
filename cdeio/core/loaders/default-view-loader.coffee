define [
    'cdeio/core/view'
    'cdeio/core/config'
], (View, config) ->
    {getPath} = config

    type: 'view'
    name: 'DEFAULT'
    fn: (module, feature, viewName, args) ->
        deferred = $.Deferred()
        options = args[0]

        # view 的 views/**(view) 默认是不加载的。
        if options?.avoidLoadingView is true
            def =
                baseName: viewName
                module: module
                feature: feature
                # view 中得 model 默认是不加载的。
                avoidLoadingModel: true
                # view 的 handler 是默认加载的。
                avoidLoadingHandlers: if options.avoidLoadingHandlers is false then false else true

            deferred.resolve View.build def
            return deferred.promise()

        module.loadResource(getPath feature, 'view', viewName).done (def = {}) ->
            def.baseName = viewName
            def.module = module
            def.feature = feature

            view = View.build def
            deferred.resolve view
        deferred.promise()
