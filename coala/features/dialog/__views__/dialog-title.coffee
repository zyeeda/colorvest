define
    extend:
        templateHelpers: ->
            title = @feature.startupOptions.title
            title: title

    avoidLoadingHandlers: true

