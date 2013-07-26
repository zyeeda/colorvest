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
            views = []
            if data.views
                views = data.views
            else
                if data.style is 'grid'
                    views.push name: 'grid:operators', region: 'operators'
                    views.push name: 'grid:grid', region: 'grid'
                else if data.style is 'tree'
                    views.push name: 'tree:operators', region: 'operators'
                    views.push name: 'tree:tree', region: 'grid'
                else if data.style is 'treeTable'
                    views.push name: 'treetable:operators', region: 'operators'
                    views.push name: 'treetable:grid', region: 'grid'

                views.push 'forms:add'
                views.push 'forms:edit'
                views.push 'forms:show'

            opts =
                baseName: featureName
                module: module
                avoidLoadingModel: true
                avoidLoadingTemplate: true

                layout: 'coala:grid'

                views: views

            if data.enableFrontendExtension is true
                module.loadResource('__scaffold__/' + featureName).done (scaffold) ->
                    opts.scaffold = scaffold
                    deferred.resolve(new Feature opts, options)
            else
                deferred.resolve(new Feature opts, options)
        deferred.promise()
