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
        @loadAddFormDeferred.done (form, title = '') =>
            grid = @feature.views['inline:grid'].components[0]
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
