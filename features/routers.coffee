define
    routes:
        "start/*path": "hello"

    hello: (path) ->
        @module.getApplication().applicationRoot.startFeature path

