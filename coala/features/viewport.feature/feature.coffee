define [
    'coala/features/viewport.feature/handlers/viewport'
    'text!coala/features/viewport.feature/templates.html'
], ->
    layout:
        regions:
            viewport: 'viewportRegion'

    views: [
        name: 'inline:viewport'
        region: 'viewport'
        events:
            'this#launcher:launch': 'launchApp'
            'this#viewport:close-feature': 'closeApp'
            'this#viewport:show-launcher': 'showLauncher'
        components: [ ->
            type: 'launcher'
            selector: 'launcherEntry'
            data: @collection.toJSON()
        , ->
            type: 'viewport'
            selector: 'viewport'
            defaultFeatureStartupOptions: @collection.toJSON()
            homepageFeaturePath: 'main/home-page'
        ]

        model: 'system/menuitems'
        extend:
            serializeData: (su) ->
                deferred = $.Deferred()
                @collection.fetch().done =>
                    deferred.resolve su.apply @
                deferred.promise()
    ]
