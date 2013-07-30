define [
    'jquery'
    'coala/core/feature'
], ($, Feature) ->

    type: 'feature'
    name: 'scaffold'
    fn: (module, feature, featureName, args) ->
        options = args[0]
        deferred = $.Deferred()

        $.get(module.url(featureName) + '/configuration/feature').done (data) ->
            opts =
                baseName: featureName
                module: module
                avoidLoadingModel: true
                avoidLoadingTemplate: true

            views = []
            if data.views
                views = data.views
            else
                if data.style is 'grid'
                    opts.layout = 'coala:grid'
                    views.push name: 'grid:toolbar', region: 'toolbar'
                    views.push name: 'grid:body', region: 'body'

                else if data.style is 'tree'
                    opts.layout = 'coala:tree'
                    views.push name: 'tree:toolbar', region: 'toolbar'
                    views.push name: 'tree:body', region: 'body'

                else if data.style is 'treeTable'
                    opts.layout = 'coala:grid'
                    views.push name: 'treetable:toolbar', region: 'toolbar'
                    views.push name: 'treetable:body', region: 'body'

                views.push 'forms:add'
                views.push 'forms:edit'
                views.push 'forms:show'

            opts.views = views

            if data.enableFrontendExtension is true
                module.loadResource('__scaffold__/' + featureName).done (scaffold) ->
                    opts.scaffold = scaffold
                    deferred.resolve(new Feature opts, options)
            else
                deferred.resolve(new Feature opts, options)
        deferred.promise()
