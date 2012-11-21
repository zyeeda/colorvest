define ["zui/coala/view", "underscore"], (View, _) ->
    showPicker: ->
        options = @feature.startupOptions
        gridOptions = undefined
        app = @feature.module.getApplication()
        root = app.applicationRoot
        unless @dialogView
            gridOptions = _.extend(options.grid or {},
                type: "grid"
                selector: "grid"
            )
            @dialogView = new View(
                baseName: "grid-picker-grid-view"
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
                label: "OK"
                fn: _.bind((me) ->
                    grid = me.dialogView.components[0]
                    selected = grid.getGridParam("selrow")
                    return false  unless selected
                    rowData = grid.getRowData(selected)
                    text = (options.toText or (data) ->
                        data.name
                    )(rowData)
                    me.$("text").val text
                    options.valueField.val selected
                    true
                , this, this)
            ]


