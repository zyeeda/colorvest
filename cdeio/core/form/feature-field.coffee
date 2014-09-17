define [
    'cdeio/core/form/form-field'
    'cdeio/cdeio'
], (FormField, cdeio) ->

    cdeio.registerComponentHandler 'form-feature-field', (->), (el, options, view) ->
        app = view.feature.module.getApplication()
        path = options.path
        ops = _.extend {}, options.options,
            ignoreExists: true
            container: el

        promise = app.startFeature path, ops
        options.field.featurePromise = promise
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
            @hideLabel = @options.hideLabel isnt false

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
                <% if (!hideLabel) { %>
                    <label class="control-label label label-info arrowed-in arrowed-in-right" for="<%= id %>"><%= label %><% if (required) { %>
                        <span class="required-mark">*</span>
                    <% } %></label>
                <% } %>
                <div class="controls">
                    <div id="<%= id %>" class="c-feature-field" <% if (height) { %>style="height: <%= height %>;"<% } %>></div>
                </div>
            </div>
        '''

    FormField.add 'feature', FeatureField

    FeatureField
