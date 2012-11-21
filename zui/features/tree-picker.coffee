define
    layout: "one-region"
    views: [
        name: "tree-picker-field"
        region: "main"
    ]
    extend:
        initRenderTarget: ->
            @container = @startupOptions.el

    avoidLoadingModel: true

