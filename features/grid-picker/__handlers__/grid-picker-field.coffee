define ['coala/core/view', 'underscore'], (View, _) ->
    showPicker: ->
        options = @feature.startupOptions
        gridOptions = undefined
        root = @feature.module.getApplication()
        unless @dialogView
            gridOptions = _.extend(options.grid or {},
                type: 'grid'
                selector: 'grid'
            ,
                if options.multiple is true
                    multiselect: true
                else
                    {}
            )
            @dialogView = new View(
                baseName: 'grid-picker-grid-view'
                feature: @feature
                module: @module
                model: options.url
                components: [gridOptions]
                avoidLoadingHandlers: true
            )
        root.showDialog
            title: options.title
            view: @dialogView
            buttons: [
                label: '确定'
                status: 'btn-primary'
                fn: _.bind((me) ->
                    grid = me.dialogView.components[0]

                    if options.multiple is true
                        selected = grid.getGridParam('selarrrow')
                    else
                        selected = grid.getGridParam('selrow')
                        selected = [selected] if selected
                    return false  unless selected
                    text = ((options.toText or (data) -> data.name)(grid.getRowData(id)) for id in selected)
                    me.$('text').val text.join ','
                    options.valueField.val selected.join ','
                    options.valueField.trigger 'change' if options.statusChanger
                    true
                , this, this)
            ]
