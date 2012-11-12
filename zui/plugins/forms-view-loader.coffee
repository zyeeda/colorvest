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
                <input type="<%= type %>" class="input" id="<%= id %>" name="<%= name %>" value="{{<%= value %>}}" <% if (readOnly) {%> readonly="true" <%}%>/>
              </div>
            </div>
        '''
        hidden: _.template '<input type="hidden" name="<%= name %>" value="{{<%= value %>}}"/>'
        string: _.template  '''
            <div class="control-group">
              <label class="control-label" for="<%= id %>"><%= label %></label>
              <div class="controls">
                <input type="text" class="input" id="<%= id %>" name="<%= name %>" value="{{<%= value %>}}" <% if (readOnly) {%> readonly="true" <%}%>/>
              </div>
            </div>
        '''
        'long-string': _.template '''
            <div class="control-group">
              <label class="control-label" for="<%= id %>"><%= label %></label>
              <div class="controls">
                <textarea class="input" id="<%= id %>" name="<%= name %>" rows="<%= rowspan %>" <% if (readOnly) {%> readonly="true" <%}%>>{{<%= value %>}}</textarea>
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
                <input type="hidden" id="<%= id %>" name="<%= name %>" value="{{appearFalse <%= value %>}}"/>
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

    generateForm = (options = {}, components, viewName) ->
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
                    generateGroup others, groupName, options.groups[groupName], components, groupStrings
                    unusedGroups = _.without unusedGroups, groupName
                id = _.uniqueId 'tab'
                tabLiStrings.push templates.tabLi(i: i, id: id, title: tab.title)
                tabContentStrings.push templates.tabContent(i: i, id: id, content: groupStrings.join(''))

            for groupName in unusedGroups
                generateGroup others, groupName, options.groups[groupName], components, unusedGroupStrings

            formContent = templates.tabLayout(lis: tabLiStrings.join(''), content: tabContentStrings.join(''), pinedGroups: unusedGroupStrings.join(''))
        else
            groupStrings = []
            generateGroup others, groupName, group, components, groupStrings for groupName, group of options.groups
            formContent = groupStrings.join('')
        columns: columns, form: templates.form(content: formContent, hiddens: generateFields(hiddens, 1), formName: viewName)

    generateGroup = (allFields, groupName, group, components, groupStrings) ->
        fields = findFieldsInGroup groupName, allFields
        return if fields.length is 0
        groupStrings.push templates.group(label: group.label, groupContent: generateFields(fields, group.columns, components))

    generateFields = (fields, columns, components) ->
        fieldStrings = []
        row = []
        if columns is 2
            items = 0
            for field in fields
                generateField field, components, row
                row.push true if field.colspan is 2
                throw new Error("the second column's colspan can not be 2") if row.length > 2
                if row.length is 2
                    template = if row[1] is true then templates.oneColumnRow else templates.twoColumnsRow
                    fieldStrings.push template(field1: row.shift(), field2: row.shift())
            fieldStrings.push(templates.oneColumnRow(field1: row.shift())) if row.length isnt 0
        else
            generateField(field, components, fieldStrings) for field in fields

        fieldStrings.join ''

    generateField = (field, components, fieldStrings) ->
        field.id = _.uniqueId field.name
        field.value = field.name if not field.value
        field.readOnly = !!field.readOnly
        if field.type is 'picker'
            if not _.isString(field.pickerSource)
                fieldStrings.push templates['staticPicker'](field)
                components.push
                    type: 'select'
                    selector: field.id
                    data: field.pickerSource
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
                    valueField: field.id
                    remoteDefined: true
        else if field.type is 'date'
            fieldStrings.push templates['string'](field)
            components.push
                type: 'datepicker'
                selector: field.id
        else if field.type is 'many-picker'
            fieldStrings.push templates['gridPicker'](field)
            components.push
                type: 'many-picker',
                selector: 'grid-' + field.id
                url: field.pickerSource
                title: '选择' + field.label
                remoteDefined: true
                fieldName: field.name
                grid:
                    datatype: 'local'
                    colModel: field.colModel
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
            {columns, form} = generateForm data, components, viewName

            view = new View
                baseName: viewName
                module: module
                feature: feature
                components: components
                avoidLoadingHandlers: true
                dialogClass: if columns is 2 then 'two-column-dialog' else 'one-column-dialog'
                extend:
                    renderHtml: (su, data) ->
                        template = Handlebars.compile form or ''
                        template(data)
            view.forms = data
            deferred.resolve view
        deferred
