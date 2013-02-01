define [
    'coala/core/layout'
    'coala/core/config'
], (Layout, config) ->
    {getPath} = config

    type: 'layout'
    name: 'DEFAULT'
    fn: (module, feature, layoutName, args) ->
        deferred = $.Deferred()

        module.loadResource(getPath feature, 'layout', layoutName).done (def) ->
            error @, 'no layout defined with name:', getPath @, 'layout', layout if not def
            def.el = feature.container
            def.baseName = if layoutName.charAt(0) is '/' then layoutName.substring(1) else layoutName
            def.feature = feature
            def.module = module
            deferred.resolve new Layout def

        deferred.promise()
