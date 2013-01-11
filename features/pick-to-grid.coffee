define [
    'coala/features/pick-to-grid/__handlers__/picker-field'
    'coala/features/pick-to-grid/__views__/picker-field'
    'coala/features/pick-to-grid/__layouts__/one-region'
    'text!coala/features/pick-to-grid/__templates__/grid-picker-grid-view.html'
    'text!coala/features/pick-to-grid/__templates__/picker-field.html'
    'text!coala/features/pick-to-grid/__templates__/one-region.html'
], ->
    layout: "one-region"
    views: [
        name: "picker-field"
        region: "main"
    ]
    ignoreExists: true
    extend:
        initRenderTarget: ->
            @container = @startupOptions.el

    avoidLoadingModel: true
