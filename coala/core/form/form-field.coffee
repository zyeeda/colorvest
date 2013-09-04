define [
    'jquery'
    'underscore'
], ($, _) ->

    class FormField
        constructor: (@form, @group, @options) ->
            @options = options = name: options if _.isString options

            @id = options.id or _.uniqueId options.name
            @name = options.name
            @value = options.value or options.name
            @label = options.label or @name
            @readOnly = !!options.readOnly
            @required = !!options.required
            @visible = true
            @type = options.type
            @colspan = options.colspan or 1
            @rowspan = options.rowspan or 1
            @statusChanger = !!options.statusChanger

        getElement: ->
            @form.$ @id

        getFormData: ->
            @form.$(@id).val()

        loadFormData: (value, data) ->
            return if value is undefined
            if _.isArray value
                idx = _.indexOf @form.findField(@name), @
                return @loadFormData value[idx]
            if @readOnly then @form.$(@id).text(value or '') else @form.$(@id).val(value)

        isReadOnly: ->
            @readOnly

        getComponents: ->
            []

        getEvents: ->
            o = {}
            if @statusChanger then o['change ' + @id] = 'formStatusChanged'
            o

        setVisible: (visible) ->
            @visible = if visible is false then false else true
            @getElement()[if @visible then 'show' else 'hide']()

        submitThisField: ->
            @visible and not @readOnly

        getTemplateString: -> '''
            <% if (readOnly) { %>
                <div class="c-view-form-field">
                    <div class="field-label"><%= label %></div><div id="<%= id %>" class="field-value">{{<%= value %>}}</div>
                </div>
            <% } else { %>
                <div class="control-group">
                    <label class="control-label" for="<%= id %>"><%= label %><% if (required) { %>
                        <span class="required-mark">*</span>
                    <% } %></label>
                  <div class="controls">
                    <input type="<%= type %>" class="input span12" id="<%= id %>" name="<%= name %>" value="{{<%= value %>}}" />
                  </div>
                </div>
            <% } %>
        '''

        getTemplate: ->
            tpl = _.template @getTemplateString()
            tpl @

        afterRender: ->
            @

    fieldTypes = {}
    FormField.add = (type, clazz) ->
        fieldTypes[type] = clazz

    FormField.build = (options, group, form) ->
        options = name: options if _.isString options
        type = options.type or 'text'
        clazz = fieldTypes[type]
        c = if clazz then clazz else FormField
        new c form, group, options

    FormField
