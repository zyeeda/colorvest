define [
    'underscore'
    'jquery'
    'cdeio/cdeio'
    'cdeio/core/config'
    'cdeio/vendors/jquery/select2/select2'
    'cdeio/vendors/jquery/select2/select2_locale_zh-CN'
], (_, $, cdeio, config) ->

    # callback = (q, view, textKey) ->
    #     data = view.collection.toJSON()
    #     (d.text = d[textKey] if not d.text) for d in data
    #     q.callback results: data, more: false


    cdeio.registerComponentHandler 'select', (->), (el, opt, view) ->
        if opt.readOnly is true
            return loadData: (data) ->
                _(opt.data).each (item) ->
                    el.html(item.text) if String(item.id) == String(data[opt.fieldName])

        options = _.extend {minimumResultsForSearch: config.minimumResultsForSearch}, opt
        options.width = '100%'
        # if options.remote is true
        #     delete options.remote
        #     options.data = []
        #     textKey = options.textKey or 'name'
        #     options.query = (q) ->
        #         if view.collection.isEmpty()
        #             $.when(view.collection.fetch()).done -> callback q, view, textKey
        #         else
        #             _.delay (-> callback q, view, textKey), 50
        selector = el.select2 options

        id = el.attr('id').split('-')
        id.shift()
        id = id.join('-')
        # events = ['change']
        # for e in events
            # selector.on(e, view.feature.delegateComponentEvent(view, {component: selector}, "select:#{id}:#{e}"))            
        if options.change && view.feature.options.scaffold.handlers[options.change]
            selector.on 'change', ->
                view.feature.options.scaffold.handlers[options.change](view, selector)

        selector.dispose = ->
            @select2 'destroy'

        selector
