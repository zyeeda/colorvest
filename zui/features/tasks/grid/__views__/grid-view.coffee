define
    model: ->
        console.log @feature.startupOptions.model
        @feature.startupOptions.model

    components: [ ->
        type: 'grid'
        selector: 'grid'
        pager: 'pager'
        colModel: @feature.startupOptions.colModel
    ]
    avoidLoadingHandlers: true
