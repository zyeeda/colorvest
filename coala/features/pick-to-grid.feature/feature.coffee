define [
    'coala/features/pick-to-grid.feature/handlers/picker-field'
    'coala/features/pick-to-grid.feature/views/picker-field'
    'text!coala/features/pick-to-grid.feature/templates.html'
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
