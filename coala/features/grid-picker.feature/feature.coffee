define [
    'coala/features/grid-picker.feature/handlers/grid-picker-field'
    'text!coala/features/grid-picker.feature/templates.html'
], ->

    layout:
        regions:
            main: 'pickerFieldRegion'

    views: [
        name: "inline:grid-picker-field"
        region: "main"
        events:
            "click showPickerBtn": "showPicker"
    ]

    extend:
        initRenderTarget: ->
            @container = @startupOptions.el

    avoidLoadingModel: true
