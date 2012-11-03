define [
    'jquery'
    'underscore'
    'zui/coala/view'
    'zui/coala/config'
], ($, _, View, config) ->
    {getPath} = config

    templates =
        operator: _.template '''
            <div class="btn-group">
              <button id="<%= id %>" class="btn">
                <% if (icon) { %>
                    <i class="<%= icon %>"/>&nbsp;
                <% } %>
                <%= label %></button>
            </div>
        '''
        tree: '''
            <ul style="width:100%;" id="tree" class="ztree"/>
        '''

    submitHandler = (viewName, title, type) ->
        view = @feature.views[viewName]
        app = @feature.module.getApplication()
        ok = ->
            values = view.$$('form').serializeArray()
            data = {}
            _(values).map (item) ->
                if item.name of data
                    data[item.name] = if _.isArray(data[item.name]) then data[item.name].concat([item.value]) else [data[item.name], item.value]
                else
                    data[item.name] = item.value
            view.model.set data
            _(view.components).each (component) ->
                if _.isFunction(component.getFormData)
                    d = component.getFormData()
                    view.model.set d.name, d.value if d

            _id = view.model.get('id')
            validator = view.$$('form').valid()
            return false if !validator
            $.when(view.model.save()).then (data) ->
                if data.violations
                    msg = ''
                    summary = ''
                    labels = view.forms.fields
                    for err in data.violations
                        unless err.properties
                            summary += err.message + '\n'
                        for label in labels
                            if label.name == err.properties
                                msg += "#{[label.label]} #{err.message}\n"
                    msg += summary
                    app.error msg, '验证提示'
                    return
                tree = view.feature.views['treeViews:tree'].components[0]
                selected = tree.getSelectedNodes()[0]
                if type is 'add'
                    tree.addNodes selected, view.model.toJSON()
                else
                    _.extend selected, view.model.toJSON()
                    tree.refresh()

                app.success '操作成功'
                app._modalDialog.modal.modal 'hide'
            , ->
                app.error '系统出错！'
            false

        app.showDialog(
            view: view
            title: title
            buttons: [label: 'Ok', fn: ok]
        ).done (dialog) ->
            v = dialog.startupOptions.view
            data = v.model.toJSON()
            _(v.components).each (component) ->
                component.loadData data if _.isFunction(component.loadData)
        .done ->
            return unless view.forms.validator
            result = view.forms.validator
            view.$$('form').validate({
                rules: view.forms.validator.rules,
                messages: view.forms.validator.messages,
                highlight: (label) ->
                    $(label).closest('.control-group').removeClass('success')
                    $(label).closest('.control-group').addClass('error')
                ,
                success: (label) ->
                    $(label).text('OK!').addClass('valid').closest('.control-group').removeClass('error')
                    $(label).text('OK!').addClass('valid').closest('.control-group').addClass('success')
            })

    generateOperatorsView = (module, feature, deferred) ->
        feature.request url:'configuration/operators', success: (data) ->
            strings = []
            for name, value of data
                value = label: value if _.isString value
                strings.push templates.operator(id: name, label: value.label, icon: value.icon)
            view = new View
                baseName: 'operators'
                module: module
                feature: feature
                events:
                    'click add': 'add'
                    'click edit': 'edit'
                    'click del': 'del'
                    'click show': 'show'
                extend:
                    renderHtml: (su, data) ->
                        template = Handlebars.compile strings.join('') or ''
                        template(data)
            view.eventHandlers.add = ->
                @feature.views['forms:add'].model.clear()
                tree = @feature.views['treeViews:tree'].components[0]
                selected = tree.getSelectedNodes()[0]
                @feature.views['forms:add'].model.set 'parent', selected if selected
                submitHandler.call @, 'forms:add', 'Create New Item', 'add'
            view.eventHandlers.edit = ->
                tree = @feature.views['treeViews:tree'].components[0]
                view = @feature.views['forms:edit']
                app = @feature.module.getApplication()
                selected = tree.getSelectedNodes()[0]
                return app.info '请选择要操作的记录' if not selected

                view.model.set selected
                $.when(view.model.fetch()).then =>
                    submitHandler.call @, 'forms:edit', 'Edit Item', 'edit'
            view.eventHandlers.del = ->
                tree = @feature.views['treeViews:tree'].components[0]
                selected = tree.getSelectedNodes()[0]
                app = @feature.module.getApplication()
                return app.info '请选择要操作的记录' if not selected

                @feature.model.set 'id', selected.id
                $.when(@feature.model.destroy()).then (data) =>
                    if data.violations
                        msg = ''; summary = ''
                        for err in data.violations
                            unless err.properties
                                summary += err.message + '\n'
                        msg += summary
                        app.error msg, '验证提示'
                        return
                    tree.removeNode selected
            view.eventHandlers.show = ->
                app = @feature.module.getApplication()
                tree = @feature.views['treeViews:tree'].components[0]
                selected = tree.getSelectedNodes()[0]
                view = @feature.views['forms:edit']
                return app.info '请选择要操作的记录' if not selected

                view.model.set 'id', selected.id
                $.when(view.model.fetch()).then ->
                    app.showDialog(
                        view: view
                        title: 'View Item'
                        buttons: []
                    ).done ->
                        view.$$('form input').attr('readonly', true)

            deferred.resolve view

    generateTreeView = (module, feature, deferred) ->
        scaffold = feature.options.scaffold or {}
        handlers = scaffold.handlers

        feature.request url:'configuration/tree', success: (data = {}) ->
            data.type = 'tree'
            data.selector = 'tree'

            view = new View
                baseName: 'operators'
                module: module
                feature: feature
                components: [data]
                events:
                    'click': 'clearSelection'
                extend:
                    renderHtml: (su, data) ->
                        templates.tree
            view.eventHandlers.clearSelection = (e) ->
                name = e.target.tagName
                if name is 'LI' or name is 'UL'
                    view.components[0].cancelSelectedNode()
            _.extend view.eventHandlers, handlers

            deferred.resolve view

    type: 'view'
    name: 'treeViews'
    fn: (module, feature, viewName, args) ->
        deferred = $.Deferred()
        console.log viewName, 'name'
        if viewName is 'operators'
            generateOperatorsView(module, feature, deferred)
        else if viewName is 'tree'
            generateTreeView(module, feature, deferred)

        deferred
