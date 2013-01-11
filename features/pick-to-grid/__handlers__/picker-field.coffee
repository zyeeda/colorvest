define ["coala/core/view", "underscore"], (View, _) ->
    showPicker: ->
        options = @feature.startupOptions
        gridOptions = undefined
        targetGrid = @components[0]
        app = @feature.module.getApplication()
        root = app.applicationRoot

        unless @dialogView
            gridOptions = _.extend(options.pickerGrid or {},
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
                    rowData = undefined
                    return false  unless selected
                    rowData = grid.getRowData(selected)
                    exists = targetGrid.getRowData(selected)
                    return false  if _.include(targetGrid.getDataIDs(), rowData.id)
                    targetGrid.addRowData rowData.id, rowData
                    options.valueField.trigger 'change' if options.statusChanger
                    true
                , this, this)
            ]


    removeItem: ->
        options = @feature.startupOptions
        gridOptions = undefined
        targetGrid = @components[0]
        selected = targetGrid.getGridParam("selrow")
        return  unless selected
        targetGrid.delRowData selected
