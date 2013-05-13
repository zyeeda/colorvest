define [
    'coala/features/tree-picker.feature/handlers/tree-picker-field'
    'text!coala/features/tree-picker.feature/templates.html'
], ->
    layout:
        regions:
            main: 'pickerFieldRegion'

    views: [
        name: 'inline:tree-picker-field'
        region: 'main'
        events:
            'click showPickerBtn': 'showPicker'
    ]

    extend:
        initRenderTarget: ->
            @container = @startupOptions.el

    avoidLoadingModel: true
