define
    showPicker: ->
        picker = @components[0]
        return unless picker
        picker.chooser.show picker

    removeItem: ->
        grid = @feature.views['inline:grid'].components[0]
        gridView = @feature.views['inline:grid']

        if _.isFunction gridView.handlers.beforeInlineGridRemove
            gridView.handlers.beforeInlineGridRemove.call @, grid, @feature.formView

        grid.removeSelectedRow()

        if _.isFunction gridView.handlers.afterInlineGridRemove
            gridView.handlers.afterInlineGridRemove.call @, grid, @feature.formView

    createItem: ->
        gridView = @feature.views['inline:grid']

        return if not @loadAddFormDeferred

        if _.isFunction gridView.beforeShowInlineGridDialog
            return unless (gridView.beforeShowInlineGridDialog.call @, 'add', @) == true

        @loadAddFormDeferred.done (form, title = '') =>
            grid = gridView.components[0]
            app.showDialog
                title: '新增' + title
                view: form
                onClose: ->
                    form.reset()
                buttons: [
                    label: '确定'
                    status: 'btn-primary'
                    fn: =>
                        return false unless form.isValid()

                        if _.isFunction gridView.validInlineGridFormData
                            return false unless (gridView.validInlineGridFormData.call @, 'add', form, form.getFormData()) == true

                        data = form.getFormData()
                        data.id = @fakeId()
                        grid.addRow data
                ]
            .done ->
                if _.isFunction gridView.afterShowInlineGridDialog
                    gridView.afterShowInlineGridDialog.call @, 'add', form, {}

    updateItem: ->
        gridView = @feature.views['inline:grid']

        return if not @loadEditFormDeferred

        if _.isFunction gridView.beforeShowInlineGridDialog
            return unless (gridView.beforeShowInlineGridDialog.call @, 'edit', @) == true

        @loadEditFormDeferred.done (form, title = '') =>
            grid = gridView.components[0]
            index = grid.getSelectedIndex()
            index = index[0] if _.isArray index
            return if index is null
            data = grid.fnGetData(index)
            app.showDialog
                title: '编辑' + title
                view: form
                onClose: ->
                    form.reset()
                buttons: [
                    label: '确定'
                    status: 'btn-primary'
                    fn: => 
                        return false unless form.isValid()

                        if _.isFunction gridView.validInlineGridFormData
                            return false unless (gridView.validInlineGridFormData.call @, 'edit', form, form.getFormData()) == true

                        d = form.getFormData()
                        d.id = @fakeId()
                        idx = grid.getSelectedIndex()
                        idx = idx[0] if _.isArray idx
                        grid.fnDeleteRow idx 
                        grid.addRow d
                ]
            .done ->
                if _.isFunction gridView.afterShowInlineGridDialog
                    gridView.afterShowInlineGridDialog.call @, 'edit', form, data
                form.setFormData(data)
