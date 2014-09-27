define [
    'underscore'
    'cdeio/core/view'
], (_, View) ->

    type: 'view'
    name: 'inline'
    fn: (module, feature, viewName, args) ->
        deferred = $.Deferred()
        options = args[0]

        def = _.extend options,
            baseName: viewName
            feature: feature
            module: module
        deferred.resolve View.build def
        deferred.promise()
