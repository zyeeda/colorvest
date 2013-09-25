define [
    'jquery'
    'underscore'
    'coala/core/form/form-field'
    'coala/core/form/feature-field'
], ($, _, FormField, FeatureField) ->

    class InlineGridField extends FeatureField
        constructor: (form, group, options) ->
            throw new Error 'path must be specified' if not options.path
            [paths..., name] = options.path.split '/'
            paths.push "scaffold:#{name}"
            path = paths.join '/'
            opt = _.extend
                hideLabel: false
                options:
                    gridOptions: deferLoading: 0, paginate: false
                    inlineGrid:
                        refKey: options.refKey
                        manyToMany: options.manyToMany is true
            , options,
                path: path
                url: options.path

            if options.allowPick is true
                opt.options.inlineGrid.picker =
                    url: options.path
                    remoteDefined: true
                    title: '选择' + options.label

            @refKey = opt.refKey
            super form, group, opt
            @type = 'inline-grid'
        afterRender: ->
            id = @form.model.id
            throw new Error 'Inline Grid only can be used in the form whose model has specified id' if not id

            @featurePromise.done (feature) =>
                feature.extraFormData = {}
                feature.extraFormData[@refKey] = id
                feature.collection.extra['_filters'] = [['eq', @refKey + '.id', id]]
                grid = feature.views['grid:body'].findComponent('grid')
                grid.refresh()

                app = feature.module.getApplication()
                picker = feature.layout.findComponent 'picker'
                manyToMany = feature.startupOptions.inlineGrid.manyToMany
                if manyToMany
                    feature.removeManyToManyReference = (selected) =>
                        values = (item.id for item in grid.fnGetData())
                        values = _.without values, selected.id
                        data = {}
                        data[@name] = if values.length is 0 then null else values

                        @form.feature.request
                            url: id, dataType: 'json', type: 'put', data: data
                        .done ->
                            grid.refresh()

                if picker
                    picker.setValue = (value) =>
                        data = {}
                        if manyToMany
                            values = (item.id for item in grid.fnGetData())
                            return if _.contains values, value.id
                            values.push value.id
                            data[@name] = values
                            @form.feature.request
                                url: id, dataType: 'json', type: 'put', data: data
                            .done ->
                                grid.refresh()
                        else
                            data[@refKey] = id
                            $.ajax app.url(@options.url) + '/' + value.id,
                                dataType: 'json', type: 'put', data: data
                            .done ->
                                grid.refresh()

        submitThisField: -> false

    FormField.add 'inline-grid', InlineGridField

    InlineGridField
