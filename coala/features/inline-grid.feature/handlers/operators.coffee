define
    showPicker: ->
        picker = @components[0]
        return unless picker
        picker.chooser.show picker

    removeItem: ->
        grid = @feature.views['inline:grid'].components[0]
        grid.removeSelectedRow()

    createItem: ->
        return if not @loadAddFormDeferred

        if _.isFunction @feature.views['inline:grid'].beforeShowInlineGridDialog
            return if (@feature.views['inline:grid'].beforeShowInlineGridDialog.call @, 'add', @) == false

        @loadAddFormDeferred.done (form, title = '') =>
            gridView = @feature.views['inline:grid']
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
                        data = form.getFormData()
                        data.id = @fakeId()
                        grid.addRow data
                ]
            .done ->
                if _.isFunction gridView.afterShowInlineGridDialog
                    gridView.afterShowInlineGridDialog.call @, 'add', @, {}

    updateItem: ->
        return if not @loadEditFormDeferred

        if _.isFunction @feature.views['inline:grid'].beforeShowInlineGridDialog
            return if (@feature.views['inline:grid'].beforeShowInlineGridDialog.call @, 'edit', @) == false

        @loadEditFormDeferred.done (form, title = '') =>
            gridView = @feature.views['inline:grid']
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
                        d = form.getFormData()
                        d.id = @fakeId()
                        grid.fnDeleteRow index
                        grid.addRow d
                ]
            .done ->
                if _.isFunction gridView.afterShowInlineGridDialog
                    gridView.afterShowInlineGridDialog.call @, 'edit', @, data
                form.setFormData(data)
