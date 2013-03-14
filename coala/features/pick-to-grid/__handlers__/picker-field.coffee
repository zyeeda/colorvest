define ["coala/core/view", "underscore"], (View, _) ->
    showPicker: ->
        options = @feature.startupOptions
        gridOptions = undefined
        targetGrid = @components[0]
        root = @feature.module.getApplication()

        unless @dialogView
            gridOptions = _.extend(options.pickerGrid or {},
                type: "grid"
                selector: "grid"
                multiselect: true
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
                    selected = grid.getGridParam("selarrrow")
                    return false if selected.length is 0
                    changed = false
                    for id in selected
                        continue if _.include(targetGrid.getDataIDs(), id)
                        changed = true
                        data = grid.getRowData id
                        targetGrid.addRowData id, data
                    options.valueField.trigger 'change' if changed and options.statusChanger
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
