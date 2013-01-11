define
    layout: "one-region"
    views: [
        name: "grid-picker-field"
        region: "main"
    ]
    avoidLoadingModel: true
    extend:
        initRenderTarget: ->
            @container = @startupOptions.el

