define
    routes:
        "start/*path": "hello"

    hello: (path) ->
        @module.getApplication().startFeature path
