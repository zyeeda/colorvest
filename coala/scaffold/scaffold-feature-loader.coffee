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

            views.push 'form:add'
            views.push 'form:edit'
            views.push 'form:show'
            views.push name: 'form:filter', region: 'filter' if data.haveFilter

            views = views.concat data.views if _.isArray(data.views)

            opts.views = views
            opts.haveFilter = data.haveFilter

            if data.enableFrontendExtension is true
                module.loadResource(featureName + '.feature/scaffold').done (scaffold) ->
                    opts.scaffold = scaffold
                    deferred.resolve(new Feature opts, options)
            else
                deferred.resolve(new Feature opts, options)
        deferred.promise()
