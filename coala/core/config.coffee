define ['config', 'underscore'], (projectConfig, _) ->
    config =
        applicationName: 'app'
        templateSuffix: '.html'
        featureContainer: 'body'
        urlPrefix: 'invoke'
        modelDefinitionPath: 'definition'
        routerFileName: 'routers'
        scriptRoot: '/scripts'
        appRoot: 'app'
        helperPath: 'invoke/helper'
        coalaFeaturesPath: 'coala/features'
        urlPrefix: 'invoke/scaffold/'
        minimumResultsForSearch: 10
        featureFileName: 'feature'

        folders:
            layout: '__layouts__'
            view: '__views__'
            model: '__models__'
            collection: '__collections__'
            handler: '__handlers__'
            template: '__templates__'

        getPath: (feature, type, path) ->
            root = true if path.charAt(0) is '/'
            path = path.substring 1 if root is true

            (if root then '/' else feature.baseName + '/') + config.folders[type] + '/' + path

    _.extend config, projectConfig
