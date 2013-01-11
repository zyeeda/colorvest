define [
    'coala/features/tree-picker/__views__/tree-picker-field'
    'coala/features/tree-picker/__layouts__/one-region'
    'coala/features/tree-picker/__handlers__/tree-picker-field'

    'text!coala/features/tree-picker/__templates__/one-region.html'
    'text!coala/features/tree-picker/__templates__/tree-picker-field.html'
    'text!coala/features/tree-picker/__templates__/tree-picker-tree-view.html'
], ->
    layout: "one-region"
    views: [
        name: "tree-picker-field"
        region: "main"
    ]
    extend:
        initRenderTarget: ->
            @container = @startupOptions.el

    avoidLoadingModel: true
