define [
    'jquery'
    'underscore'
    'cdeio/core/form/form-field'
    'cdeio/core/form/feature-field'
], ($, _, FormField, FeatureField) ->

    class InlineGridField extends FeatureField
        constructor: (form, group, options) ->
            throw new Error 'source must be specified' if not options.source
            opt = _.extend
                hideLabel: false
                path: 'cdeio:inline-grid'
                options:
                    allowPick: options.allowPick, allowAdd: options.allowAdd, allowEdit: options.allowEdit, url: options.source, readOnly: options.readOnly || options.disabled
                    gridOptions: deferLoading: 0, paginate: false, multiple: options.multiple is true, form: form
                    loadViewFormDeferred: options.loadViewFormDeferred or undefined, disableShow: options.disableShow
            , options
            # 用于流程历史历史信息 inline-grid 使用
            if options.needDeferLoading is false
                delete opt.options.gridOptions.deferLoading

            _.extend opt.options.gridOptions, options.grid
            if options.allowPick is true
                opt.options.picker =
                    url: options.source
                    remoteDefined: true
                    title: '选择' + (options.label or '')
                    multiple: options.multiple is true
                    crossPage: options.crossPage is true
                    type: options.pickerType
            super form, group, opt
            @type = 'inline-grid'

    FormField.add 'inline-grid', InlineGridField

    InlineGridField
