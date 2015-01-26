define ['config', 'underscore'], (projectConfig, _) ->

    config =
        applicationName: 'app'
        templateSuffix: '.html'
        featureContainer: 'body'
        modelDefinitionPath: 'definition'
        routerFileName: 'routers'
        scriptRoot: '/scripts'
        appRoot: 'app'
        helperPath: 'invoke/helper'
        cdeioFeaturesPath: 'cdeio/features'
        urlPrefix: 'invoke/scaffold/'
        minimumResultsForSearch: 10
        featureFileName: 'feature'
        whitelist: []

        folders:
            layout: 'layouts'
            view: 'views'
            model: 'models'
            collection: 'collections'
            handler: 'handlers'
            template: 'templates'

        getPath: (feature, type, path) ->
            root = true if path.charAt(0) is '/'
            path = path.substring 1 if root is true

            (if root then '/' else feature.baseName + '.feature/') + config.folders[type] + '/' + path

    _.extend config, projectConfig
