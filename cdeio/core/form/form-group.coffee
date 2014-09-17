define [
    'jquery'
    'underscore'
    'cdeio/core/form/form-field'
], ($, _, FormField) ->

    class FormGroup
        constructor: (@form, @options, @fieldOptions) ->
            @options = options = name: options if _.isString options
            @cols = @options.columns if @options.columns
            @fieldOptions = fieldOptions = [fieldOptions] if not _.isArray fieldOptions
            @containerId = _.uniqueId 'group'

            @visible = @options.visible isnt false
            @hiddenFields = []
            @fields = []
            for field in fieldOptions
                if @options.readOnly is true
                    field = name: field, type: 'text' if _.isString field
                    field.readOnly = true
                if @options.disabled is true
                    field.disabled = true
                (if field.type is 'hidden' then @hiddenFields else @fields).push FormField.build field, @, form


        getColumns: ->
            if not @cols
                @cols = 1
                @cols = 2 for field in @fields when field.colspan is 2
            throw new Error "unsupported columns:#{@cols}, only can be: 1, 2, 3, 4, 6, 12" if 12 % @cols isnt 0
            @cols

        getTemplateString: -> '''
            <fieldset id="<%= containerId %>" class="c-form-group-cols-<%= columns %>" style="<% if (!visible) {%>display:none<%}%>">
                <% if (label) { %>
                <legend><span class="label label-info arrowed-in arrowed-in-right"><%= label %></span></legend>
                <% } %>
                <%= groupContent %>
            </fieldset>
        '''

        setVisible: (visible) ->
            @visible = if visible is false then false else true
            @form.$(@containerId)[if @visible then 'show' else 'hide']()
            field.setVisible @visible for field in @fields

        getRowTemplate: -> _.template '''<div class="row-fluid"><%= items %></div>'''
        getItemTemplate: ->_.template  '''<div class="span<%= span %>"><%= field %></div>'''

        getTemplate: ->
            contents = []
            columns = @getColumns()
            span = 12 / columns
            row = []
            newRow = =>
                contents.push @getRowTemplate() items: row.join('')
                row = []

            for field, i in @fields
                colspan = field.colspan or 1
                colspan = columns if colspan > columns

                newRow() if row.length + colspan > columns
                row.push @getItemTemplate() span: colspan * span, field: field.getTemplate()
                row.push '' for i in [1...colspan]
                newRow() if row.length is columns
            newRow() if row.length > 0

            _.template(@getTemplateString())
                label: @options.label,
                groupContent: contents.join(''),
                containerId: @containerId
                columns: @getColumns()
                visible: @visible

        getHiddenFieldsTemplate: ->
            (field.getTemplate() for field in @hiddenFields).join ''
