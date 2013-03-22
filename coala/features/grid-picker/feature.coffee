define [
    'coala/features/grid-picker/__handlers__/grid-picker-field'
    'text!coala/features/grid-picker/templates.html'
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
