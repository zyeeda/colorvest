define [
    'jquery'
    'underscore'
    'coala/core/form/form-field'
], ($, _, FormField) ->

    class FormGroup
        constructor: (@form, @options, @fieldOptions) ->
            @options = options = name: options if _.isString options
            @cols = @options.columns if @options.columns
            @fieldOptions = fieldOptions = [fieldOptions] if not _.isArray fieldOptions
            @containerId = _.uniqueId 'group'

            @hiddenFields = []
            @fields = []
            for field in fieldOptions
                if @options.readOnly is true
                    filed = name: field if _.isString field
                    field.readOnly = true
                (if field.type is 'hidden' then @hiddenFields else @fields).push FormField.build field, @, form

        getColumns: ->
            if not @cols
                @cols = 1
                @cols = 2 for field in @fields when field.colspan is 2
            @cols

        getTemplateString: -> '''
            <fieldset id="<%= containerId %>">
                <% if (label) { %>
                <legend><%= label %></legend>
                <% } %>
                <%= groupContent %>
            </fieldset>
        '''

        setVisible: (visible) ->
            @visible = if visible is false then false else true
            @form.$(@containerId)[if @visible then 'show' else 'hide']()
            field.setVisible @visible for field in @fields

        getRowTemplate: (cols) ->
            if not @twoRowTemplate
                @twoRowTemplate = _.template '''
                    <div class="row-fluid">
                        <div class="span6">
                            <%= field1 %>
                        </div>
                        <div class="span6">
                            <%= field2 %>
                        </div>
                    </div>
                '''
            if not @oneRowTemplate
                @oneRowTemplate = _.template '''
                    <div class="row-fluid">
                        <div class="span12">
                            <%= field1 %>
                        </div>
                    </div>
                '''
            if cols is 2 then @twoRowTemplate else @oneRowTemplate

        getTemplate: ->
            contents = []
            if @getColumns() is 1
                contents.push @getRowTemplate(1) field1: field.getTemplate() for field in @fields
            else if @getColumns() is 2
                row = []
                for field, i in @fields
                    if row.length + field.colspan > 2
                        contents.push @getRowTemplate(2) field1: row.join(''), field2: ''
                        row = []
                    row.push field.getTemplate()
                    row.push true if field.colspan is 2
                    if row.length is 2
                        contents.push @getRowTemplate(if row[1] isnt true then 2 else 1) field1: row[0], field2: row[1] or ''
                        row = []
                    if (i + 1) is @fields.length and row.length is 1
                        contents.push @getRowTemplate(2) field1: row[0], field2: '<div class="control-group"></div>'
            _.template(@getTemplateString()) label: @options.label, groupContent: contents.join(''), containerId: @containerId

        getHiddenFieldsTemplate: ->
            (field.getTemplate() for field in @hiddenFields).join ''
