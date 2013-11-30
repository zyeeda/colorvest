define [
    'jquery'
    'underscore'
    'coala/core/form/form-field'
    'coala/core/form/feature-field'
], ($, _, FormField, FeatureField) ->

    class InlineGridField extends FeatureField
        constructor: (form, group, options) ->
            throw new Error 'source must be specified' if not options.source
            opt = _.extend
                hideLabel: false
                path: 'coala:inline-grid'
                options:
                    allowPick: options.allowPick, allowAdd: options.allowAdd, url: options.source, readOnly: options.readOnly
                    gridOptions: deferLoading: 0, paginate: false, multiple: options.multiple is true, form: form
            , options
            _.extend opt.options.gridOptions, options.grid

            if options.allowPick is true
                opt.options.picker =
                    url: options.source
                    remoteDefined: true
                    title: '选择' + (options.label or '')
                    multiple: options.multiple is true
                    type: options.pickerType

            super form, group, opt
            @type = 'inline-grid'

    FormField.add 'inline-grid', InlineGridField

    InlineGridField
