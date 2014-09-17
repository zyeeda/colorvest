define [
    'backbone'
    'underscore'
    'jquery'
], (Backbone, _, $) ->

    Sync =
        online: (method, model, options) ->
            type = Sync.methodMap[method]
            params = type: type, dataType: 'json', url: model.url(), contentType: 'application/x-www-form-urlencoded'
            if not options.data and model and (method is 'create' or method is 'update')
                params.data = _.extend model.toJSON(), options.data or {}
                delete options.data

            params = _.extend params, options
            beforeRequest = options.beforeRequest or model.beforeRequest
            if _.isFunction beforeRequest
                beforeRequest params, model, method

            $.ajax _.extend params, options

        offline: (method, model, options = {}) ->

        storeForOffline: (model) ->

        methodMap:
            'create': 'POST'
            'update': 'PUT'
            'delete': 'DELETE'
            'read': 'GET'

        fn: (method, model, options = {}) ->
            o = _.extend {}, options
            if window.navigator.onLine
                Sync.online method, model, o
            else
                Sync.offline method, model, o

    Backbone.sync = Sync.fn
    Sync
