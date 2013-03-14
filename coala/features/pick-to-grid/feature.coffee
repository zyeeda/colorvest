define [
    'coala/features/pick-to-grid/__handlers__/picker-field'
    'coala/features/pick-to-grid/__views__/picker-field'
    'text!coala/features/pick-to-grid/templates.html'
], ->
    layout: "coala:one-region"
    views: [
        name: "picker-field"
        region: "main"
    ]
    ignoreExists: true
    extend:
        initRenderTarget: ->
            @container = @startupOptions.el

    avoidLoadingModel: true
