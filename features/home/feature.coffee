define
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
        ,
            type: 'viewport'
            selector: 'viewport'
        ]

        model: 'system/menuitems'
        extend:
            serializeData: (su) ->
                deferred = $.Deferred()
                @collection.fetch().done =>
                    deferred.resolve su.apply @
                deferred.promise()
    ]
