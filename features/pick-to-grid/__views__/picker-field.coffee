define
    events:
        "click show-picker": "showPicker"
        "click remove-item": "removeItem"

    components: [->
        options = @feature.startupOptions.grid or {}
        options.type = "grid"
        options.selector = "grid"
        options
    ]

    extend:
        templateHelpers: ->
            fieldReadOnly: @feature.startupOptions.readOnly
