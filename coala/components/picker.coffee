define [
    'underscore'
    'jquery'
    'coala/coala'
], (_, $, coala) ->

    coala.registerComponentHandler 'grid-picker', (->), (el, opt = {}, view) ->
        if opt.readOnly is true
            return loadData: (data) ->
                el.html data[opt.fieldName]?['name']

        app = view.feature.module.getApplication()
        options = _.extend el: el, ignoreExists: true, opt
        options.valueField = view.$ options.valueField
        result = deferred: $.Deferred()
        if options.remoteDefined
            $.get view.feature.module.getApplication().url(options.url + '/configuration/picker'), (data) ->
                _.extend options, data
                app.startFeature('coala:grid-picker', options).done (feature) ->
                    result.feature = feature
                    result.deferred.resolve feature
        else
            app.startFeature('coala:grid-picker', options).done (feature) ->
                result.feature = feature
                result.deferred.resolve feature

        result.loadData = (data) ->
            value = data[options.fieldName]
            return if not value
            result.deferred.done (feature) ->
                feature.views['inline:grid-picker-field'].$('text').val(value.name)
                options.valueField.val(value.id)

        result

    coala.registerComponentHandler 'tree-picker', (->), (el, opt = {}, view) ->
        if opt.readOnly is true
            return loadData: (data) ->
                el.html data[opt.fieldName]?['name']

        app = view.feature.module.getApplication()
        options = _.extend el: el, ignoreExists: true, opt
        options.valueField = view.$ options.valueField
        app.startFeature 'coala:tree-picker', options
        result = deferred: $.Deferred()
        if options.remoteDefined
            $.get view.feature.module.getApplication().url(options.url + '/configuration/picker'), (data) ->
                _.extend options, data
                app.startFeature('coala:tree-picker', options).done (feature) ->
                    result.feature = feature
                    result.deferred.resolve feature
        else
            app.startFeature('coala:tree-picker', options).done (feature) ->
                result.feature = feature
                result.deferred.resolve feature

        result.loadData = (data) ->
            value = data[options.fieldName]
            return if not value
            result.deferred.done (feature) ->
                feature.views['inline:tree-picker-field'].$('text').val(value.name)
                options.valueField.val(value.id)

        result

    coala.registerComponentHandler 'many-picker', (->), (el, opt = {}, view) ->
        app = view.feature.module.getApplication()
        options = _.extend el: el, ignoreExists: true, opt
        options.valueField = view.$ options.valueField
        result = deferred: $.Deferred()
        extendFeature = (feature) ->
            feature.getFormData = ->
                result.feature.views['picker-field'].components[0].getDataIDs()
            feature.loadData = (data) ->
                values = data[options.fieldName]
                @views['picker-field'].components[0][0].addJSONData rows: values

        if options.remoteDefined
            $.get view.feature.module.getApplication().url(options.url + '/configuration/picker'), (data) ->
                options.pickerGrid = data?.grid
                app.startFeature('coala:pick-to-grid', options).done (feature) ->
                    result.feature = feature
                    extendFeature feature
                    result.deferred.resolve feature
        else
            app.startFeature('coala:pick-to-grid', options).done (feature) ->
                result.feature = feature
                extendFeature feature
                result.deferred.resolve feature

        result.deferred
