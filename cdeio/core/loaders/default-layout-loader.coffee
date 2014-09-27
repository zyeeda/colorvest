define [
    'underscore'
    'cdeio/core/layout'
    'cdeio/core/config'
    'cdeio/core/util'
], (_, Layout, config, util) ->
    {getPath} = config
    {error} = util

    type: 'layout'
    name: 'DEFAULT'
    fn: (module, feature, layoutName, args) ->
        deferred = $.Deferred()
        [d] = args

        if _.isObject d
            def = _.extend d,
                baseName: layoutName or feature.baseName
                el: feature.container
                feature: feature
                module: module
            deferred.resolve new Layout def
        else
            module.loadResource(getPath feature, 'layout', layoutName).done (def) ->
                error @, "No layout defined with name #{getPath @, 'layout', layoutName}." if not def
                #error @, 'no layout defined with name:', getPath @, 'layout', layoutName if not def
                def.el = feature.container
                def.baseName = if layoutName.charAt(0) is '/' then layoutName.substring(1) else layoutName
                def.feature = feature
                def.module = module
                deferred.resolve new Layout def

        deferred.promise()
