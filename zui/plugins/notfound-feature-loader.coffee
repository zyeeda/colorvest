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
                if data.type is 'grid'
                    views.push name: 'views:operators', region: 'operators'
                    views.push name: 'views:grid', region: 'grid'
                else if data.type is 'tree'
                    views.push name: 'treeViews:operators', region: 'operators'
                    views.push name: 'treeViews:tree', region: 'grid'
                else if data.type is 'treeTable'
                    views.push name: 'treeTableViews:operators', region: 'operators'
                    views.push name: 'treeTableViews:grid', region: 'grid'

                views.push 'forms:add'
                views.push 'forms:edit'

            opts =
                baseName: featureName
                module: module
                container: container if container?

                layout: '/grid'

                views: views
            deferred.resolve(new Feature opts, options)
        deferred
