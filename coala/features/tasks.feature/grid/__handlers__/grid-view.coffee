define
    selectChanged: (feature, view, grid, args...) ->
        id = grid.getGridParam('selrow')
        buttonView = feature.formView.dialogFeature.views['dialog-buttons']
        button = buttonView.buttons[0]

        el = buttonView.$ button.id
        button.taskId = id
        if id then el.removeClass 'disabled' else el.addClass 'disabled'
