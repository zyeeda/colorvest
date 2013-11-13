define ['jquery', 'underscore', 'coala/core/form-view'], ($, _, FormView) ->

    layout:
        regions:
            operators: 'operators'
            grid: 'body'

    views: [
        name: 'inline:operators', region: 'operators',
        components: [ ->
            {picker, readOnly} = @feature.startupOptions
            if picker and not readOnly
                _.extend type: 'grid-picker', selector: 'picker', picker
        ]
        events:
            'click pick': 'showPicker'
            'click remove': 'removeItem'
            'click add': 'createItem'
        extend:
            fakeId: (su, id) ->
                if id then id.indexOf('FAKEID-') is 0 else _.uniqueId 'FAKEID-'

            afterRender: (su) ->
                su.apply @
                picker = @components[0]

                if picker
                    grid = @feature.views['inline:grid'].components[0]
                    picker.setValue = (value) ->
                        data = grid.fnGetData()
                        for v in value
                            exists = false
                            exists = true for d in data when d.id is v.id
                            grid.addRow v if not exists
                    picker.getFormData = ->
                        grid.fnGetData()

                if @feature.startupOptions.allowAdd
                    return if @loadAddFormDeferred
                    @loadAddFormDeferred = $.Deferred()

                    app = @feature.module.getApplication()
                    url = app.url @feature.startupOptions.url + '/configuration/forms/add'
                    $.get(url).done (data) =>
                        def = _.extend
                            baseName: 'add'
                            module: @feature.module
                            feature: @feature
                            avoidLoadingHandlers: true
                            entityLabel: data.entityLabel
                            formName: 'add'
                        , data
                        def.form =
                            groups: data.groups or []
                            tabs: data.tabs

                        view = new FormView def
                        @loadAddFormDeferred.resolve view, data.entityLabel

            serializeData: (su) ->
                data = su.apply @
                data.allowPick = @feature.startupOptions.allowPick
                data.allowAdd = @feature.startupOptions.allowAdd
                data.readOnly = @feature.startupOptions.readOnly

                data
    ,
        name: 'inline:grid', region: 'grid', avoidLoadingHandlers: true,
        components: [ ->
            _.extend
                type: 'grid'
                selector: 'grid'
                data: []
                fixedHeader: false
            , @feature.startupOptions.gridOptions
        ]
    ]

    extend:
        loadFormData: (ignore, values) ->
            grid = @views['inline:grid'].components[0]
            grid.addRow d for d in values or []

        getFormData: ->
            grid = @views['inline:grid'].components[0]
            view = @views['inline:operators']
            data = grid.fnGetData()
            return [null] if not data.length
            ids = []
            ids.push d.id for d in data when not view.fakeId(d.id)
            for d in data
                if view.fakeId(d.id)
                    dd = _.extend {}, d
                    delete dd.id
                    ids.push dd
            ids
