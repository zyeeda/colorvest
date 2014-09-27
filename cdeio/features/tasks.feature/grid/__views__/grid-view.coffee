define
    events:
        'this#grid:onSelectRow': 'selectChanged'

    model: ->
        @feature.startupOptions.model

    components: [ ->
        type: 'grid'
        selector: 'grid'
        pager: 'pager'
        colModel: @feature.startupOptions.colModel
    ]
