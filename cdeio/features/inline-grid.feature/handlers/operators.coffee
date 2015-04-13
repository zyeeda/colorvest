define
    showPicker: ->
        picker = @components[0]
        return unless picker

        gridView = @feature.views['inline:grid']

        beforeShowPicker = picker.options.beforeShowPicker
        scaffold = @feature.startupOptions.gridOptions.form.feature.options.scaffold or {}
        handlers = scaffold.handlers or {}

        feature = @feature
        pickerFeatureType = 'feature'

        if feature.baseName is 'inline-grid'
            feature = feature.startupOptions.gridOptions.form.feature
            pickerFeatureType = 'inline-grid'

        pickerFiled = picker.name or ''
        pickerFeatureName = feature.baseName

        if _.isFunction handlers[beforeShowPicker]
            return unless (handlers[beforeShowPicker].call @, gridView, pickerFiled, pickerFeatureType, pickerFeatureName) is true

        picker.chooser.show(picker).done (feature) ->
            removeSelectedNodes() if removeSelectedNodes = feature.inRegionViews.body.components[0].removeSelectedNodes

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
            return unless (gridView.beforeShowInlineGridDialog.call @, 'add', @) is true

        @loadAddFormDeferred.done (form, title = '') =>
            grid = gridView.components[0]
            app.showDialog
                title: '新增' + title
                view: form
                onClose: ->
                    form.unbindAll()
                    _.each form.components, (v, i) ->
                        if v.chooser
                            $('#text-' + v.id, $('span'), form.$el).text ''
                    form.reset()
                buttons: [
                    label: '确定'
                    status: 'btn-primary'
                    fn: =>
                        return false unless form.isValid()

                        if _.isFunction gridView.validInlineGridFormData
                            return false unless (gridView.validInlineGridFormData.call @, 'add', form, form.getFormData()) is true

                        data = form.getFormData()
                        data.id = @fakeId()
                        grid.addRow data
                ]
            .done ->
                form.reset()
                if _.isFunction gridView.afterShowInlineGridDialog
                    gridView.afterShowInlineGridDialog.call @, 'add', form, form.getFormData()

    updateItem: ->
        gridView = @feature.views['inline:grid']

        return if not @loadEditFormDeferred

        if _.isFunction gridView.beforeShowInlineGridDialog
            return unless (gridView.beforeShowInlineGridDialog.call @, 'edit', @) is true

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
                    form.unbindAll()
                    _.each form.components, (v, i) ->
                        if v.chooser
                            $('#text-' + v.id, $('span'), form.$el).text ''
                    form.reset()
                buttons: [
                    label: '确定'
                    status: 'btn-primary'
                    fn: =>
                        return false unless form.isValid()

                        if _.isFunction gridView.validInlineGridFormData
                            return false unless (gridView.validInlineGridFormData.call @, 'edit', form, form.getFormData()) is true

                        d = form.getFormData()
                        # 更新有id，不需要再自动生成
                        # d.id = @fakeId()
                        idx = grid.getSelectedIndex()
                        idx = idx[0] if _.isArray idx
                        grid.fnDeleteRow idx
                        grid.addRow d
                ]
            .done ->
                form.setFormData data, true
                if _.isFunction gridView.afterShowInlineGridDialog
                    gridView.afterShowInlineGridDialog.call @, 'edit', form, data
    showItem: ->
        gridView = @feature.views['inline:grid']

        return if not @loadViewFormDeferred

        if _.isFunction gridView.beforeShowInlineGridDialog
            return unless (gridView.beforeShowInlineGridDialog.call @, 'show', @) is true

        @loadViewFormDeferred.done (form, title = '') =>
            grid = gridView.components[0]
            index = grid.getSelectedIndex()
            index = index[0] if _.isArray index
            return if index is null
            data = grid.fnGetData(index)
            app.showDialog
                title: '查看' + title
                view: form
                buttons: []
            .done ->
                form.setFormData data, true
                if _.isFunction gridView.afterShowInlineGridDialog
                    gridView.afterShowInlineGridDialog.call @, 'show', form, data
