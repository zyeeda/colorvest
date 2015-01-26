define [
    'jquery'
    'underscore'
    'cdeio/core/view'
    'handlebars'
    'cdeio/core/form/form-field'
    'cdeio/core/form/form-group'
    'cdeio/core/loader-plugin-manager'
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
], ($, _, View, Handlebars, FormField, FormGroup, loaderPluginManager) ->

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
    class ProcessFormView extends View
        constructor: (options) ->
            console.log 'process-form-view--constructor options', options
            opt = _.extend {}, options
            @initForm opt.form, opt.fieldGroups, opt
            _.extend opt,
                avoidLoadingModel: true

            super opt

        initForm: (form, fieldGroups, options) ->
            # form 下的 group
            url = options.feature.url()
            # _.last(form.groups).columns = undefined
            fieldGroups['history-group'] = [
                {
                    type: 'inline-grid'
                    "allowPick": false
                    "pickerType": "grid-picker"
                    "disableShow": true
                    allowEdit: false
                    allowAdd: false
                    needDeferLoading: false
                    readOnly: true
                    loadViewFormDeferred: true
                    "source": url
                    grid:
                        columns:[
                            {name:'name', header:'任务名称', width: 160},
                            {name:'assigneeName', header:'执行人', width: 80},
                            {name:'startTime', header:'开始时间', width: 160},
                            {name:'claimTime', header:'认领时间', width: 160},
                            {name:'endTime', header:'完成时间', width: 160},
                            {name:'comment', header:'意见', width: 160}
                        ]
                }
            ]

            groups = form.groups
            groups = if _.isArray groups then groups else [groups]
            @groups = (@createGroup group, fieldGroups for group in groups)

            events = {}
            components = []
            if form.tabs
                unusedGroups = @groups.slice 0
                for tab in form.tabs
                    groups = tab.groups
                    groups = if _.isArray groups then groups else [groups]
                    tab.id = _.uniqueId 'tab'
                    events['shown a-' + tab.id] = 'form-change-tab' # What is form-change-tab?
                    for group in groups
                        # 每次循环后都将已经处理的从 unsedGroups 中删除
                        unusedGroups = _.without unusedGroups, @findGroup(group)
                        @eachField group, (field) ->
                            # 字段可以定义 event 事件 ？
                            _.extend events, es if (es = field.getEvents())
                            cs = field.getComponents()
                            c.delay = tab.id for c in cs or []
                            components = components.concat cs if cs
                for group in unusedGroups
                    @needExtraComponentRender = true
                    @eachField group.options.name, (field) ->
                        _.extend events, es if (es = field.getEvents())
                        components = components.concat cs if (cs = field.getComponents())

                @defaultComponentDelay = form.tabs[0].id

                # tab 点击时执行的方法，渲染相应的 field 组件
                (@eventHandlers or = {})['form-change-tab'] = (e) =>
                    id = $(e.target).attr('id') # view62-a-tab61
                    console.log 'process-form-view --- initForm id = ', id
                    id = id.match(/a\-(\w+)/)[1] # tab61
                    console.log 'process-form-view --- initForm after match id = ', id
                    @renderComponents id
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

        setFormData: (data = {}, onlyExists) ->
            @eachField (field) ->
                if onlyExists is true
                    field.loadFormData data[field.name], data if _.has data, field.name
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
            validator = @$$('form').validate
                rules: @options.validation.rules
                ignore: @options.validation.ignore or ''
                onfocusout: (el) ->
                    validator.element el
                errorPlacement: (error, element) ->
                    $el = $ element
                    elPos = $el.position()
                    $(error).css
                        color: '#CC0000'
                        position: 'absolute'
                        top: (elPos.top + $el.outerHeight())
                        #right: $el.parents('.modal-body').outerWidth() - elPos.left - $el.outerWidth()
                    $(error).insertAfter element
                highlight: (label) ->
                    $(label).closest('.control-group').addClass('error')
                success: (label) ->
                    $(label).closest('.control-group').removeClass('error')
                    $(label).remove()

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
                    if tab.title in ['基本信息', '历史信息']
                        tabContent =  @getTabContentTemplate() content: (for group, index in groups
                            group = @findGroup(group)
                            unused = _.without unused, group
                            # console.log 'groups.lenght', groups.length
                            # 小于2 为 历史信息，历史信息只包含一个 group
                            if groups.length <2 or ( groups.length is 2 and _.isEmpty(@model.get('_t_taskId')) )
                                single = true
                                group.options.label = null
                            else
                                single = false

                            # 任务id 为空表示流程已经结束，不显示任务信息
                            if _.isEmpty(@model.get('_t_taskId')) and  group.options.name is 'task-info-group'
                                ''
                            else
                                group.getTemplate(single, index)
                        ).join(''), id: id, i: i
                    else
                        tabContent =  @getProcessTabContentTemplate() content: (for group in groups
                            group = @findGroup(group)
                            unused = _.without unused, group
                            group.getTemplate(true, 0)
                        ).join(''), id: id, i: i, processInstanceId: @model.get('processInstanceId')
                    contents.push tabContent
                # 表示没有在 tab 中使用到的组，显示在所有的 tab 的上方
                unused = []
                oo = pinedGroups: (group.getTemplate() for group in unused).join(''), lis: lis.join(''), content: contents.join('')
                o.content = @getTabLayoutTemplate() oo
            else
                # o.content = (group.getTemplate() for group in @groups).join ''
                useableGroups = (group for group in @groups when not _.isEmpty group.fields)
                single = true if useableGroups.length is 1
                o.content = (group.getTemplate(single, index) for group, index in useableGroups).join ''

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
        getProcessTabContentTemplate: -> _.template '''
            <div class="tab-pane <%if (i == 0) {%>active<%}%>" id="<%= id %>">
                <%= content %>
                <br/><br/>
                <div>
                    <img src="invoke/scaffold/bpm/diagram/processInstanceId/<%= processInstanceId %>" />
                </div>
            </div>
        '''
        getHistoryTabContentTemplate: -> _.template '''
            <div class="tab-pane" id="<%= id %>">
                <%= content %>
            </div>
        '''
    ProcessFormView.FormGroup = FormGroup

    View.add 'process-form-view', ProcessFormView

    ProcessFormView
