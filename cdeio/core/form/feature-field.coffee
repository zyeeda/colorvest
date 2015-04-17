define [
    'cdeio/core/form/form-field'
    'cdeio/cdeio'
], (FormField, cdeio) ->

    cdeio.registerComponentHandler 'form-feature-field', (->), (el, options, view) ->
        app = view.feature.module.getApplication()
        path = options.path
        ops = _.extend {}, options.options,
            label: if options.field.hideLabel is true then '' else options.field.label
            ignoreExists: true
            container: el

        promise = app.startFeature path, ops
        options.field.featurePromise = promise
        promise.done (feature) ->
            options.field.feature = feature
            options.field.getFormData = feature.getFormData.bind feature \
                if feature.getFormData
            options.field.loadFormData = feature.loadFormData.bind feature \
                if feature.loadFormData

            feature.formView = view
            feature.formField = options.field
        promise

    class FeatureField extends FormField
        constructor: (form, group, options) ->
            super form, group, options
            @type = 'feature'
            @height = options.height
            @hideLabel = not not options.hideLabel

        getComponents: -> [
            selector: @id
            type: 'form-feature-field'
            name: @options.name
            path: @options.path
            options: @options.options
            field: @
        ]

        getFormData: ->

        getTemplateString: -> '''
            <div class="control-group">
                <div class="controls">
                    <div id="<%= id %>" class="c-form-feature-field" <% if (height) { %>style="height: <%= height %>;"<% } %>></div>
                </div>
            </div>
        '''

    FormField.add 'feature', FeatureField

    FeatureField
