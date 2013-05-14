define [
    'coala/core/form/form-field'
    'coala/coala'
    'underscore'
], (FormField, coala) ->

    coala.registerComponentHandler 'form-feature-field', (->), (el, options, view) ->
        app = view.feature.module.getApplication()
        path = options.path
        ops = _.extend {}, options.options,
            ignoreExists: true
            container: el

        promise = app.startFeature path, ops
        promise.done (feature) ->
            options.field.feature = feature
            options.field.getFormData = feature.getFormData.bind feature if feature.getFormData
            options.field.loadFormData = feature.loadFormData.bind feature if feature.loadFormData

            feature.formView = view
            feature.formField = options.field
        promise



    class FeatureField extends FormField
        constructor: ->
            super
            @type = 'feature'
            @height = @options.height

        getComponents: -> [
            selector: @id
            type: 'form-feature-field'

            path: @options.path
            options: @options.options
            field: @
        ]

        getTemplateString: ->
            '<div id="<%= id %>" <% if (height) { %>style="height: <%= height %>;"<% } %>></div>'

    FormField.add 'feature', FeatureField

    FeatureField
