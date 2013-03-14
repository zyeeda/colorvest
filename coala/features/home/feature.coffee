define [
    'coala/features/home/__handlers__/viewport'
    'text!coala/features/home/templates.html'
    ], ->
    layout:
        regions:
            viewport: 'viewportRegion'

    views: [
        name: 'inline:viewport'
        region: 'viewport'
        events:
            'this#launcher:launch': 'launchApp'
            'this#viewport:close-feature': 'closeFeature'
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
