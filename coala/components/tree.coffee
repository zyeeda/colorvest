define [
    'underscore'
    'jquery'
    'coala/coala'
    'coala/vendors/jquery/ztree/jquery.ztree.all'
], (_, $, coala) ->

    addTreeData = (tree, data, parent = null, extraProperties) ->
        simpleData = tree.setting.data.simpleData
        if _.isFunction simpleData.pId
            value.pId = simpleData.pId(value) for value in data
            delete simpleData.pId # Why must delete tree.data.simpleData.pId?

        (_.extend(value, extraProperties) if extraProperties) for value in data
        tree.addNodes parent, data, true

    loadAllData = (view, tree) ->
        $.when(view.collection.fetch()).done ->
            data = view.collection.toJSON()
            addTreeData tree, data

    normalEvents = [
        'beforeAsync', 'beforeCheck', 'beforeClick', 'beforeCollapse', 'beforeDblClick'
        'beforeExpand', 'beforeRightClick', 'onAsyncError', 'onAsyncSuccess', 'onCheck'
        'onClick', 'onCollapse', 'onDblClick', 'onExpand', 'onRightClick'
    ]
    dndEvents = ['beforeDrag', 'beforeDragOpen', 'beforeDrop', 'onDrag', 'onDrop']
    editEvents = ['beforeEditName', 'beforeRemove', 'beforeRename', 'onNodeCreated', 'onRemove', 'onRename']
    mouseEvents = ['beforeMouseDown', 'beforeMouseUp', 'onMouseDown', 'onMouseUp']

    coala.registerComponentHandler 'tree', (->), (el, opt, view) ->
        options = _.extend {}, opt
        delete options.async

        options.data or= {}
        simpleData = _.extend {}, options.data.simpleData
        simpleData.enable = true
        simpleData.pId = ((dataRow) -> dataRow.parent?.id) if not simpleData.pId
        options.data.simpleData = simpleData

        cbEvents = [].concat normalEvents
        cbEvents = cbEvents.concat dndEvents if options.enableDndEvents is true
        cbEvents = cbEvents.concat editEvents if options.enableEditEvents is true
        cbEvents = cbEvents.concat mouseEvents if options.enableMouseEvents is true

        callback = _.extend {}, options.callback
        cb = {}
        eventHost = {}

        for name in cbEvents
            cb[name] = view.feature.delegateComponentEvent(view, eventHost, 'tree:' + name, callback[name])
            delete callback[name]
        for name, value of callback
            cb[name] = view.bindEventHandler value
        options.callback = cb

        if options.treeData
            $.fn.zTree.init el, options, options.treeData
        else
            if options.treeDataAsync is true
                tree = $.fn.zTree.init el, options, []
                loadAllData view, tree
            else
                options.callback.beforeExpand = (treeId, d) ->
                    return if d?['__inited'] is true
                    d and d['__inited'] = true

                    tree = $.fn.zTree.getZTreeObj treeId
                    simpleData = tree.setting.data.simpleData

                    idName = simpleData.idKey or 'id'
                    #id = if d is null then (if tree.parentValueOfRoot then tree.parentValueOfRoot else false) else d[idName]
                    id = if d is null then (if simpleData.rootPId then simpleData.rootPId else false) else d[idName]
                    filters = if id then [{ name: 'parent.id', operator: 'eq', value: id }] else [{ name: 'parent', operator: 'isNull' }]
                    $.when(view.collection.fetch data: { _filters: JSON.stringify(filters) }).done (data) ->
                        addTreeData tree, view.collection.toJSON(), d, isParent: true

                tree = $.fn.zTree.init el, options, null
                options.callback.beforeExpand tree.setting.treeId, null

        tree.reload = ->
            return if options.treeData

            data = $.fn.zTree._z.data
            data.initCache @setting
            data.initRoot @setting
            @setting.treeObj.empty()

            if options.treeDataAsync is true
                loadAllData @
            else
                tree.setting.callback.beforeExpand @setting.treeId, null

        eventHost.component = tree
        tree
