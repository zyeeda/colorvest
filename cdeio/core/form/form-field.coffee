define [
    'jquery'
    'underscore'
], ($, _) ->

    class FormField
        constructor: (@form, @group, @options) ->
            @options = options = name: options if _.isString options

            @id = options.id or _.uniqueId (options.name or '').replace(/\./g, '_')
            @name = options.name
            @value = options.value or options.name
            # if @form.constructor.name is 'CustomFormView'
            @hideLabel = options.hideLabel
            @label = options.label or @name
            @readOnly = !!options.readOnly
            @disabled = !!options.disabled
            @required = !!options.required
            @visible = true
            @type = options.type
            @colspan = options.colspan or 1
            @rowspan = options.rowspan or 1
            # rows 用于textarea高度，转换成height才生效, 24px一行
            @height = (options.rows or 3) * 24
            @statusChanger = !!options.statusChanger
            @multiple = options.multiple

        getElement: ->
            @form.$ @id

        getFormData: ->
            @form.$(@id).val()

        loadFormData: (value, data) ->
            value = @options.defaultValue or '' if value == null or value == undefined
            value = data[@value] if @value isnt @name
            if _.isArray value
                idx = _.indexOf @form.findField(@name), @
                return @loadFormData value[idx]
            if @readOnly then @form.$(@id).text(value) else @form.$(@id).val(value)
        
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

        getFilter: ->
            value = @getFormData()
            return null unless value
            [@filterOperator or 'like', @name, value]

        getTemplateString: -> '''
            <% if (readOnly) { %>
                <div class="c-view-form-field">
                    <% if (!hideLabel) { %>
                    <div class="field-label"><%= label %></div>
                    <% } %>
                    <div id="<%= id %>" class="field-value">{{<%= value %>}}</div>
                </div>
            <% } else { %>
                <div class="control-group">
                    <% if (!hideLabel) { %>
                    <label class="control-label" for="<%= id %>"><%= label %><% if (required) { %>
                        <span class="required-mark">*</span>
                    <% } %></label><% } %>
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
