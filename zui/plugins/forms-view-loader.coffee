define [
    'zui/coala/view'
    'handlebars'
    'underscore'
], (View, Handlebars, _) ->

    templates =
        unknown: _.template '''
            <div class="control-group">
              <label class="control-label" for="<%= id %>"><%= label %></label>
              <div class="controls">
                <% if (readOnly) { %>
                    <span>{{<%= value %>}}</span>
                <% } else { %>
                    <input type="<%= type %>" class="input" id="<%= id %>" name="<%= name %>" value="{{<%= value %>}}" />
                <% } %>
              </div>
            </div>
        '''
        hidden: _.template '<input type="hidden" name="<%= name %>" value="{{<%= value %>}}"/>'
        string: _.template  '''
            <div class="control-group">
              <label class="control-label" for="<%= id %>"><%= label %></label>
              <div class="controls">
                <% if (readOnly) { %>
                    <span>{{<%= value %>}}</span>
                <% } else { %>
                    <input type="text" class="input" id="<%= id %>" name="<%= name %>" value="{{<%= value %>}}"/>
                <% } %>
              </div>
            </div>
        '''
        'long-string': _.template '''
            <div class="control-group">
              <label class="control-label" for="<%= id %>"><%= label %></label>
              <div class="controls">
                <% if (readOnly) { %>
                    <span>{{<%= value %>}}</span>
                <% } else { %>
                    <textarea class="input" id="<%= id %>" name="<%= name %>" rows="<%= rowspan %>">{{<%= value %>}}</textarea>
                <%  } %>
              </div>
            </div>
        '''
        group: _.template '''
            <fieldset>
                <% if (label) { %>
                <legend><%= label %></legend>
                <% } %>
                <%= groupContent %>
            </fieldset>
        '''
        staticPicker: _.template  '''
            <div class="control-group">
              <label class="control-label" for="<%= id %>"><%= label %></label>
              <div class="controls">
                <% if (readOnly) {%>
                    <span id="<%= id %>"/>
                <% } else { %>
                    <input type="hidden" id="<%= id %>" name="<%= name %>" value="{{appearFalse <%= value %>}}"/>
                <% } %>
              </div>
            </div>
        '''
        gridPicker: _.template '''
            <div class="control-group">
              <label class="control-label" for="<%= id %>"><%= label %></label>
              <div class="controls">
                <input type="hidden" id="<%= id %>" name="<%= name %>" value="{{appearFalse <%= value %>}}"/>
                <div id="grid-<%= id %>"></div>
              </div>
            </div>
        '''
        form: _.template '''
            <form class="form-horizontal">
                <%= content %>
                <%= hiddens %>
                <input type="hidden" name="__formName__" value="<%= formName %>"/>
            </form>
        '''
        tabLayout: _.template '''
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
        tabLi: _.template '''
            <li <% if (i == 0) {%>class="active" <%}%>><a data-target="<%= id %>" data-toggle="tab"><%= title %></a></li>
        '''
        tabContent: _.template '''
            <div class="tab-pane <%if (i == 0) {%>active<%}%>" id="<%= id %>">
                <%= content %>
            </div>
        '''
        twoColumnsRow: _.template '''
            <div class="row-fluid">
                <div class="span6">
                    <%= field1 %>
                </div>
                <div class="span6">
                    <%= field2 %>
                </div>
            </div>
        '''
        oneColumnRow: _.template '''
            <div class="row-fluid">
                <div class="span12">
                    <%= field1 %>
                </div>
            </div>
        '''
        twoColumnsForm: _.template '''
            <form class="form-horizontal container-fluid">
                <%= content %>
                <%= hiddens %>
            </form>
        '''
        manyPicker: _.template '''
            <div class="control-group">
              <label class="control-label" for="<%= id %>"><%= label %></label>
              <div class="controls">
                <div id="grid-<%= id %>"></div>
              </div>
            </div>
        '''
        featureField: _.template '''
            <div id="<%= id %>"></div>
        '''

    generateForm = (options = {}, components, viewName, features) ->
        hiddens = []
        others = []
        (if field.type is 'hidden' then hiddens else others).push field for field in options.fields or []

        columns = 1
        unusedGroups = (for groupName, group of options.groups
            group.columns = columns = 2 if group.columns > 1
            groupName
        )

        formContent = ''
        if options.tabs
            tabLiStrings = []
            tabContentStrings = []
            unusedGroupStrings = []
            for tab, i in options.tabs
                groupStrings = []
                for groupName in tab.groups
                    generateGroup others, groupName, options.groups[groupName], components, groupStrings, features
                    unusedGroups = _.without unusedGroups, groupName
                id = _.uniqueId 'tab'
                tabLiStrings.push templates.tabLi(i: i, id: id, title: tab.title)
                tabContentStrings.push templates.tabContent(i: i, id: id, content: groupStrings.join(''))

            for groupName in unusedGroups
                generateGroup others, groupName, options.groups[groupName], components, unusedGroupStrings, features

            formContent = templates.tabLayout(lis: tabLiStrings.join(''), content: tabContentStrings.join(''), pinedGroups: unusedGroupStrings.join(''))
        else
            groupStrings = []
            generateGroup others, groupName, group, components, groupStrings, features for groupName, group of options.groups
            formContent = groupStrings.join('')
        columns: columns, form: templates.form(content: formContent, hiddens: generateFields(hiddens, 1), formName: viewName)

    generateGroup = (allFields, groupName, group, components, groupStrings, features) ->
        fields = findFieldsInGroup groupName, allFields
        return if fields.length is 0
        groupStrings.push templates.group(label: group.label, groupContent: generateFields(fields, group.columns, components, features))

    generateFields = (fields, columns, components, features) ->
        fieldStrings = []
        row = []
        if columns is 2
            items = 0
            for field in fields
                generateField field, components, row, features
                row.push true if field.colspan is 2
                throw new Error("the second column's colspan can not be 2") if row.length > 2
                if row.length is 2
                    template = if row[1] is true then templates.oneColumnRow else templates.twoColumnsRow
                    fieldStrings.push template(field1: row.shift(), field2: row.shift())
            fieldStrings.push(templates.oneColumnRow(field1: row.shift())) if row.length isnt 0
        else
            generateField(field, components, fieldStrings, features) for field in fields

        fieldStrings.join ''

    generators =
        picker: (field, components, fieldStrings, features) ->
            if not _.isString(field.pickerSource)
                fieldStrings.push templates['staticPicker'](field)
                components.push
                    type: 'select'
                    selector: field.id
                    data: field.pickerSource
                    fieldName: field.name
                    readOnly: field.readOnly
                    initSelection: (el, fn) ->
                        val = $(el).val()
                        return fn(field.pickerSource[0]) if not val
                        return if not val
                        _(field.pickerSource).each (item) ->
                            fn(item) if String(item.id) == String(val)
            else
                fieldStrings.push templates['gridPicker'](field)
                components.push
                    type: 'grid-picker'
                    selector: 'grid-' + field.id
                    url: field.pickerSource
                    title: '选择' + field.label
                    fieldName: field.name
                    readOnly: field.readOnly
                    valueField: field.id
                    remoteDefined: true

        date: (field, components, fieldStrings, features) ->
            fieldStrings.push templates['string'](field)
            components.push type: 'datepicker', selector: field.id if not field.readOnly

        'many-picker': (field, components, fieldStrings, features) ->
            fieldStrings.push templates['gridPicker'](field)
            components.push
                type: 'many-picker',
                selector: 'grid-' + field.id
                url: field.pickerSource
                title: '选择' + field.label
                remoteDefined: true
                fieldName: field.name
                readOnly: field.readOnly
                grid:
                    datatype: 'local'
                    colModel: field.colModel
        feature: (field, components, fieldStrings, features) ->
            fieldStrings.push templates['featureField'](field)
            features.push
                id: field.id
                path: field.path
                options: field.options


    generateField = (field, components, fieldStrings, features) ->
        field.id = _.uniqueId field.name
        field.value = field.name if not field.value
        field.readOnly = !!field.readOnly
        if _.isFunction generators[field.type]
            generators[field.type](field, components, fieldStrings, features)
        else if templates[field.type]
            fieldStrings.push templates[field.type](field)
        else
            fieldStrings.push templates.unknown(field)

    findFieldsInGroup = (name, fields) ->
        field for field in fields when field.group is name

    type: 'view'
    name: 'forms'
    fn: (module, feature, viewName, args) ->
        deferred = $.Deferred()
        feature.request url:'configuration/forms/' + viewName, success: (data) ->
            components = []
            features = []
            {columns, form} = generateForm data, components, viewName, features

            view = new View
                baseName: viewName
                module: module
                feature: feature
                components: components
                avoidLoadingHandlers: true
                dialogClass: if columns is 2 then 'two-column-dialog' else 'one-column-dialog'
                entityLabel: data.entityLabel
                extend:
                    renderHtml: (su, data) ->
                        template = Handlebars.compile form or ''
                        template(data)
                    afterRender: ->
                        app = @feature.module.getApplication()
                        deferred = $.Deferred()
                        promises = []
                        for featureConfig in features
                            container = @$ featureConfig.id
                            opts = _.extend {}, featureConfig.options
                            opts.container = container
                            opts.ignoreExists = true
                            p = app.startFeature featureConfig.path, opts
                            promises.push p
                        $.when.apply($, promises).then -> deferred.resolve()
                        deferred
            view.forms = data
            deferred.resolve view
        deferred
