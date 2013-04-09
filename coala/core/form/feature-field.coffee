define [
    'coala/core/form/form-field'
], (FormField) ->

    class FeatureField extends FormField
        constructor: ->
            super
            @type = 'feature'
            @height = @options.height

        getTemplateString: ->
            '<div id="<%= id %>" <% if (height) { %>style="height: <%= height %>;"<% } %>></div>'

        afterRender: ->
            app = @form.feature.module.getApplication()
            path =  @options.path
            container = @form.$ @id
            options = _.extend {}, @options.options,
                ignoreExists: true
                container: @form.$ @id

            promise = app.startFeature path, options

            promise.done (feature) =>
                @feature = feature
                @getFormData = feature.getFormData.bind feature if feature.getFormData
                @loadFormData = feature.loadFormData.bind feature if feature.loadFormData

                feature.formView = @form

            promise

    FormField.add 'feature', FeatureField

    FeatureField
