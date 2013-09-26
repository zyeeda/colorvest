define [
    'underscore'
    'jquery'
    'coala/coala'
    'coala/vendors/jquery/ztree/jquery.ztree.all'
], (_, $, coala) ->

    addTreeData = (tree, data, parent = null, extraProperties, root) ->
        simpleData = tree.setting.data.simpleData
        if _.isFunction simpleData.pId
            value.pId = simpleData.pId(value) for value in data
            delete simpleData.pId # Why must delete tree.data.simpleData.pId?

        (_.extend(value, extraProperties) if extraProperties) for value in data
        if root
            resetId data, root
            data.unshift root
        tree.addNodes parent, data, false

    loadAllData = (view, tree, root) ->
        $.when(view.collection.fetch()).done ->
            data = view.collection.toJSON()
            addTreeData tree, data, null, null, root

    resetId = (nodes, root) ->
        for d in nodes
            d.pId = root.id if not d.pId and root.id is '-1'

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

        root = name: options.root, isRoot: true, open: true, isParent: true, id: options.data?.rootPid or '-1' if options.root

        if options.treeData
            if root
                resetId options.treeData, root
                tree = $.fn.zTree.init el, options, [root].concat options.treeData
            else
                tree = $.fn.zTree.init el, options, options.treeData
        else
            if options.isAsync is true
                options.callback.onExpand = (e, treeId, treeNode) ->
                    return if treeNode?['__inited'] is true
                    treeNode and treeNode['__inited'] = true

                    tree = $.fn.zTree.getZTreeObj treeId
                    simpleData = tree.setting.data.simpleData

                    idName = simpleData.idKey or 'id'
                    id = if treeNode is null then (if simpleData.rootPId then simpleData.rootPId else false) else treeNode[idName]
                    id = null if id is '-1'
                    filters = if id then [['eq', 'parent.id', id]] else [['null', 'parent']]
                    $.when(view.collection.fetch data: { _filters: filters }).done (data) ->
                        addTreeData tree, view.collection.toJSON(), treeNode, isParent: true

                defaultRoot = if root then [root] else []
                tree = $.fn.zTree.init el, options, defaultRoot
                options.callback.onExpand null, tree.setting.treeId, tree.getNodeByParam('id', root.id)
            else
                tree = $.fn.zTree.init el, options, []
                loadAllData view, tree, root

        tree.reload = ->
            return if options.treeData

            data = $.fn.zTree._z.data
            data.initCache @setting
            data.initRoot @setting
            @setting.treeObj.empty()

            if options.isAsync is true
                tree.setting.callback.onExpand null, @setting.treeId, null
            else
                loadAllData view, tree

        bk = tree.getSelectedNodes
        tree.getSelectedNodes = ->
            nodes = bk.apply tree
            node for node in nodes when not node.isRoot

        eventHost.component = tree
        tree
