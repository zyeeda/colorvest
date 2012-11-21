define
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

