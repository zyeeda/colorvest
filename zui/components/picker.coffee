define [
    'underscore'
    'jquery'
    'zui/coala'
], (_, $, coala) ->

    coala.registerComponentHandler 'grid-picker', (->), (el, opt = {}, view) ->
        app = view.feature.module.getApplication()
        options = _.extend el: el, opt
        options.valueField = view.$ options.valueField
        result = deferred: $.Deferred()
        if options.remoteDefined
            $.get view.feature.module.getApplication().url(options.url + '/configuration/picker'), (data) ->
                _.extend options, data
                app.startFeature('coala/grid-picker', true, options).done (feature) ->
                    result.feature = feature
                    result.deferred.resolve feature
        else
            app.startFeature('coala/grid-picker', true, options).done (feature) ->
                result.feature = feature
                result.deferred.resolve feature

        result.loadData = (data) ->
            value = data[options.fieldName]
            return if not value
            result.deferred.done (feature) ->
                feature.views['grid-picker-field'].$('text').val(value.name)

        result

    coala.registerComponentHandler 'tree-picker', (->), (el, opt = {}, view) ->
        app = view.feature.module.getApplication()
        options = _.extend el: el, opt
        options.valueField = view.$ options.valueField
        app.startFeature 'coala/tree-picker', true, options

    coala.registerComponentHandler 'many-picker', (->), (el, opt = {}, view) ->
        app = view.feature.module.getApplication()
        options = _.extend el: el, opt
        options.valueField = view.$ options.valueField
        result = deferred: $.Deferred()
        if options.remoteDefined
            $.get view.feature.module.getApplication().url(options.url + '/configuration/picker'), (data) ->
                options.pickerGrid = data?.grid
                app.startFeature('coala/pick-to-grid', true, options).done (feature) ->
                    result.feature = feature
                    result.deferred.resolve feature
        else
            app.startFeature('coala/pick-to-grid', true, options).done (feature) ->
                result.feature = feature
                result.deferred.resolve feature

        result.getFormData = ->
            name: options.fieldName
            value: result.feature.views['picker-field'].components[0].getDataIDs()
        result.loadData = (data) ->
            values = data[options.fieldName]
            result.deferred.done ->
                result.feature.views['picker-field'].components[0][0].addJSONData rows: values

        result
