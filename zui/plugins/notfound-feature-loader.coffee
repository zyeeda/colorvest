define [
    'jquery'
    'zui/coala/feature'
], ($, Feature) ->

    type: 'feature'
    name: 'notfound'
    fn: (module, feature, featureName, args) ->
        [container, options] = args
        deferred = $.Deferred()

        $.when($.get(module.url(featureName) + '/configuration/feature')).done (data) ->
            views = []
            if data.views
                views = data.views
            else
                if data.style is 'grid'
                    views.push name: 'views:operators', region: 'operators'
                    views.push name: 'views:grid', region: 'grid'
                else if data.style is 'tree'
                    views.push name: 'treeViews:operators', region: 'operators'
                    views.push name: 'treeViews:tree', region: 'grid'
                else if data.style is 'treeTable'
                    views.push name: 'treeTableViews:operators', region: 'operators'
                    views.push name: 'treeTableViews:grid', region: 'grid'

                views.push 'forms:add'
                views.push 'forms:edit'

            opts =
                baseName: featureName
                module: module
                target: container if container?
                avoidLoadingModel: true

                layout: '/grid'

                views: views

            if data.enableFrontendExtension is true
                module.loadResource('__scaffold__/' + featureName).done (scaffold) ->
                    opts.scaffold = scaffold
                    deferred.resolve(new Feature opts, options)
            else
                deferred.resolve(new Feature opts, options)
        deferred
