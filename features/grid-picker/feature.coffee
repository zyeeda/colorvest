define [
    'coala/features/grid-picker/__handlers__/grid-picker-field'
    'text!coala/features/grid-picker/templates.html'
], ->

    layout: "coala:one-region"
    views: [
        name: "inline:grid-picker-field"
        events:
            "click show-picker": "showPicker"
        region: "main"
    ]
    avoidLoadingModel: true
    extend:
        initRenderTarget: ->
            @container = @startupOptions.el
