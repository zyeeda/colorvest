define [
    'coala/features/tree-picker/__views__/tree-picker-field'
    'coala/features/tree-picker/__handlers__/tree-picker-field'
    'text!coala/features/tree-picker/templates.html'
], ->
    layout: "coala:one-region"
    views: [
        name: "tree-picker-field"
        region: "main"
    ]
    extend:
        initRenderTarget: ->
            @container = @startupOptions.el

    avoidLoadingModel: true
