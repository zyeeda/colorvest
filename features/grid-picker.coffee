define [
    'coala/features/grid-picker/__handlers__/grid-picker-field'
    'coala/features/grid-picker/__views__/grid-picker-field'
    'text!coala/features/grid-picker/templates.html'
], ->

    layout: "coala:one-region"
    views: [
        name: "grid-picker-field"
        region: "main"
    ]
    avoidLoadingModel: true
    extend:
        initRenderTarget: ->
            @container = @startupOptions.el
