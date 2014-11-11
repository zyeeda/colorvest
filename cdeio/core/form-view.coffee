define [
    'jquery'
    'underscore'
    'cdeio/core/view'
    'handlebars'
    'cdeio/core/form/form-field'
    'cdeio/core/form/form-group'
    'cdeio/core/form/text-field'
    'cdeio/core/form/date-picker-field'
    'cdeio/core/form/date-time-picker-field'
    'cdeio/core/form/textarea-field'
    'cdeio/core/form/dropdown-field'
    'cdeio/core/form/feature-field'
    'cdeio/core/form/hidden-field'
    'cdeio/core/form/file-picker-field'
    'cdeio/core/form/mask-field'
    'cdeio/core/form/number-range-field'
    'cdeio/core/form/date-range-field'
    'cdeio/core/form/inline-grid-field'
    'cdeio/vendors/jquery/validation/messages_zh'
    #'cdeio/vendors/jquery/validation/jquery.validate' # check it later
    'cdeio/vendors/jquery/jquery.tooltipster.min'
], ($, _, View, Handlebars, FormField, FormGroup) ->

    ###
    # formName: 'add'
    # fieldGroups:
    #     group1: ['field1']
    #     group2: ['field2']
    # form:
    #     tabs: [
    #         {title: 'tab1', groups: ['group1', 'group2']}
    #     ]
    #     groups: ['group1', 'group2']
    ###
    class FormView extends View
        constructor: (options) ->
            opt = _.extend {}, options
            @initForm opt.form, opt.fieldGroups, opt
            _.extend opt,
                avoidLoadingModel: true

            super opt

        initForm: (form, fieldGroups, options) ->
            groups = form.groups
            groups = if _.isArray groups then groups else [groups]
            @groups = (@createGroup group, fieldGroups for group in groups)

            events = {}
            components = []
            if form.tabs
                unused = @groups.slice 0
                for tab in form.tabs
                    groups = tab.groups
                    groups = if _.isArray groups then groups else [groups]
                    tab.id = _.uniqueId 'tab'
                    events['shown a-' + tab.id] = 'form-change-tab' # What is form-change-tab?
                    for group in groups
                        unused = _.without unused, @findGroup(group)
                        @eachField group, (field) ->
                            _.extend events, es if (es = field.getEvents())
                            cs = field.getComponents()
                            c.delay = tab.id for c in cs or []
                            components = components.concat cs if cs
                for group in unused
                    @needExtraComponentRender = true
                    @eachField group.options.name, (field) ->
                        _.extend events, es if (es = field.getEvents())
                        components = components.concat cs if (cs = field.getComponents())

                @defaultComponentDelay = form.tabs[0].id
                (@eventHandlers or = {})['form-change-tab'] = (e) =>
                    id = $(e.target).attr('id')
                    id = id.match(/a\-(\w+)/)[1]
                    deferred = @renderComponents id
                    (deferred.done (components) => @setTabFormData components) if deferred
            else
                @eachField (field) ->
                    _.extend events, es if (es = field.getEvents())
                    components = components.concat cs if (cs = field.getComponents())

            options.events = _.extend options.events or {}, events
            options.components = (options.components or []).concat components

        createGroup: (group, fieldGroups) ->
            g = if _.isString group then name: group else group
            new FormGroup @, g, fieldGroups[g.name]

        eachField: (group, fn) ->
            if _.isFunction group
                fn = group
                group = null

            return if not _.isFunction fn

            if group
                group = @findGroup group
                fields = group.fields.concat group.hiddenFields
                fn field for field in fields
            else
                for group in @groups
                    fields = group.fields.concat group.hiddenFields
                    fn field for field in fields

        findGroup: (name) ->
            g = group for group in @groups when group.options.name is name
            g

        findField: (name, group) ->
            fields = []
            @eachField group, (field) ->
                fields.push field if field.name is name
            fields

        isValid: ->
            @$$('form').valid()

        getFormData: ->
            data = {}
            @eachField (field) =>
                return if not field.submitThisField()
                return if field.getFormData() is null
                if data[field.name] isnt undefined
                    data[field.name] = [data[field.name]] if not _.isArray data[field.name]
                    data[field.name].push field.getFormData()
                else
                    data[field.name] = field.getFormData()
            @model.clear()
            @model.set data
            @model.toJSON()

        getFilters: ->
            filters = []
            @eachField (field) =>
                filter = field.getFilter()
                filters.push filter if filter
            filters

        setTabFormData: (components) ->
            data = @model.toJSON()
            @eachField (field) ->
                _.each components, (n, i) ->
                    if n && n['__options__'].name == field.name
                        field.loadFormData data[field.name], data if _.has(data, field.name) or ' __ID__ __FORM_TYPE__ __FORM__FLAG__'.indexOf(field.name) > 0

        setFormData: (data = {}, onlyExists) ->
            @eachField (field) ->
                if onlyExists is true
                    field.loadFormData data[field.name], data if _.has(data, field.name) or ' __ID__ __FORM_TYPE__ __FORM__FLAG__'.indexOf(field.name) > 0  
                else
                    field.loadFormData data[field.name], data

        reset: ->
            @setFormData {}

        fetchData: (id) ->
            @model.clear()
            @model.set 'id', id
            @model.fetch().done  =>
                @setFormData @model.toJSON()

        submit: (options) ->
            deferred = $.Deferred()
            if not @isValid()
                deferred.reject()
            else
                @getFormData()
                @model.set @feature.extraFormData if @feature.extraFormData
                @model.set options
                @model.unset 'id' if @model.get('id') is ''
                @model.save()
                .done (data) ->
                    deferred.resolve data
                .fail (data) ->
                    deferred.reject()
            deferred.promise()

        getMaxColumns: ->
            i = 1
            i = group.getColumns() for group in @groups when i < group.getColumns()
            i

        afterRender: ->
            deferred = $.Deferred()
            promises = []
            promises.push @renderComponents() if @needExtraComponentRender is true
            @eachField (field) ->
                promises.push field.afterRender()
                if field.disabled
                    if ' grid-picker tree-picker file-picker'.indexOf(field.type) > 0
                        $('#trigger-a-' + field.id, field.form.$el).unbind().css('cursor', 'not-allowed')
                    else
                        field.form.$(field.id).attr('disabled', true)
            
            $.when.apply($, promises).then =>
                $.when(@bindValidation()).then ->
                    deferred.resolve @
            deferred.promise()

        bindValidation: ->
            # check it later
            return if not @options.validation
            options = @options
            validator = @$$('form').validate
                rules: @options.validation.rules
                ignore: @options.validation.ignore or ''
                onfocusout: (el) ->
                    validator.element el
                errorPlacement: (error, element) ->
                    $el = $ element
                    if options.validation.errorsAppend
                        elPos = $el.position()
                        $(error).css
                            color: '#CC0000'
                            position: 'absolute'
                            top: (elPos.top + $el.outerHeight())
                            #right: $el.parents('.modal-body').outerWidth() - elPos.left - $el.outerWidth()
                        $(error).insertAfter element
                    else
                        $el.tooltipster 'destroy' if $el.hasClass('tooltipstered')
                        $(error).css color: '#CC0000'
                        $el.tooltipster content: $(error), contentAsHTML: true, theme: 'tooltipster-shadow'
                highlight: (label) ->
                    $(label).closest('.control-group').addClass('error')
                success: (label, element) ->
                    if options.validation.errorsAppend      
                        $(label).closest('.control-group').removeClass('error')
                        $(label).remove()
                    else
                        $(element).tooltipster 'destroy' 
                        $(element).closest('.control-group').removeClass('error')
                        $(element).attr('title', '')

        getTemplate: ->
            style = 'form-horizontal' if @options.labelOnTop is false
            style += ' c-action-form c-action-form-' + @options.formName if @options.formName?

            o = formClass: style, formName: @options.formName

            if @options.form.tabs
                unused = @groups.slice 0
                lis = []
                contents = []
                for tab, i in @options.form.tabs
                    id = tab.id
                    lis.push @getTabLiTemplate() i: i, title: tab.title, id: id
                    groups = tab.groups
                    groups = if _.isArray groups then groups else [groups]
                    contents.push @getTabContentTemplate() content: (for group in groups
                        group = @findGroup(group)
                        unused = _.without unused, group
                        group.getTemplate()
                    ).join(''), id: id, i: i
                oo = pinedGroups: (group.getTemplate() for group in unused).join(''), lis: lis.join(''), content: contents.join('')
                o.content = @getTabLayoutTemplate() oo
            else
                o.content = (group.getTemplate() for group in @groups).join ''

            o.hiddens = (group.getHiddenFieldsTemplate() for group in @groups).join ''
            _.template(@getTemplateString()) o

        renderHtml: (data) ->
            Handlebars.compile(@getTemplate()) data

        getTemplateString: -> '''
            <form class="<%= formClass %>">
                <%= content %>
                <%= hiddens %>
                <input type="hidden" name="__FORM_NAME__" value="<%= formName %>"/>
            </form>
        '''
        getTabLayoutTemplate: -> _.template '''
            <%= pinedGroups %>
            <div>
                <ul class="nav nav-tabs">
                    <%= lis %>
                </ul>
                <div class="tab-content">
                    <%= content %>
                </div>
            </div>
        '''
        getTabLiTemplate: -> _.template '''
            <li <% if (i == 0) {%>class="active" <%}%>><a data-target="<%= id %>" id="a-<%= id %>" data-toggle="tab"><%= title %></a></li>
        '''

        getTabContentTemplate: -> _.template '''
            <div class="tab-pane <%if (i == 0) {%>active<%}%>" id="<%= id %>">
                <%= content %>
            </div>
        '''

    FormView.FormGroup = FormGroup

    View.add 'form-view', FormView

    FormView
