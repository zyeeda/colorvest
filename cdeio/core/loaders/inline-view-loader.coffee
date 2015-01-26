define [
    'underscore'
    'cdeio/core/view'
], (_, View) ->

    type: 'view'
    name: 'inline'
    fn: (module, feature, viewName, args) ->
        deferred = $.Deferred()
        options = args[0]

        # inline-view 没有加载视图资源所以不支持扩展视图。（与 default-view-loader 不同） 
        def = _.extend options,
            baseName: viewName
            feature: feature
            module: module
        deferred.resolve View.build def
        deferred.promise()
