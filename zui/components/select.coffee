define [
    'underscore'
    'jquery'
    'zui/coala'
    'zui/coala/config'
    'libs/jquery/select2/select2'
], (_, $, coala, config) ->

    callback = (q, view, textKey) ->
        data = view.collection.toJSON()
        (d.text = d[textKey] if not d.text) for d in data
        q.callback results: data, more: false


    coala.registerComponentHandler 'select', (->), (el, opt, view) ->
        options = _.extend {minimumResultsForSearch: config.minimumResultsForSearch}, opt

        if options.remote is true
            delete options.remote
            options.data = []
            textKey = options.textKey or 'name'
            options.query = (q) ->
                if view.collection.isEmpty()
                    $.when(view.collection.fetch()).done -> callback q, view, textKey
                else
                    _.delay (-> callback q, view, textKey), 50

        selector = el.select2 options
