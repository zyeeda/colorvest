define [
    'jquery'
    'underscore'
    'coala/core/view'
    'handlebars'
    'coala/core/form/form-field'
    'coala/core/form/form-group'
    'coala/core/form/text-field'
    'coala/core/form/date-picker-field'
    'coala/core/form/textarea-field'
    'coala/core/form/dropdown-field'
    'coala/core/form/feature-field'
    'coala/core/form/hidden-field'
    'coala/vendors/jquery/validation/messages_zh'
    #'coala/vendors/jquery/validation/jquery.validate' # check it later
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

        setFormData: (data = {}) ->
            @eachField (field) ->
                field.loadFormData data[field.name], data

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
                @model.set options
                @model.save().done (data) ->
                    deferred.resolve data

            deferred.promise()

        getMaxColumns: ->
            i = 1
            i = group.getColumns() for group in @groups when i < group.getColumns()
            i

        afterRender: ->
            deferred = $.Deferred()
            promises = []
            @eachField (field) ->
                promises.push field.afterRender()

            $.when.apply($, promises).then =>
                $.when(@bindValidation()).then ->
                    deferred.resolve @
            deferred.promise()

        bindValidation: ->
            # check it later
            if @options.validation then @$$('form').validate
                rules: @options.validation.rules
                #messages: @options.validation.messages
                errorPlacement: (error, element) ->
                    elPos = $(element).position()
                    #$(error).addClass 'label label-important'
                    $(error).css
                        color: '#CC0000'
                        position: 'absolute'
                        top: elPos.top + $(element).outerHeight()
                        left: elPos.left
                    $(error).insertAfter element
                highlight: (label) ->
                    $(label).closest('.control-group').addClass('error')
                success: (label) ->
                    $(label).closest('.control-group').removeClass('error')
                    $(label).remove()

        getTemplate: ->
            o = formClass: 'container-fluid', formName: @options.formName

            if @options.form.tabs
                unused = @groups.slice 0
                lis = []
                contents = []
                for tab, i in @options.form.tabs
                    id = _.uniqueId 'tab'
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
                <input type="hidden" name="__formName__" value="<%= formName %>"/>
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
            <li <% if (i == 0) {%>class="active" <%}%>><a data-target="<%= id %>" data-toggle="tab"><%= title %></a></li>
        '''
        getTabContentTemplate: -> _.template '''
            <div class="tab-pane <%if (i == 0) {%>active<%}%>" id="<%= id %>">
                <%= content %>
            </div>
        '''

    FormView.FormGroup = FormGroup

    View.add 'form-view', FormView

    FormView
