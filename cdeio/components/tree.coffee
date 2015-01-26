define [
    'underscore'
    'jquery'
    'cdeio/cdeio'
    'cdeio/vendors/jquery/ztree/jquery.ztree.all'
], (_, $, cdeio) ->

    addTreeData = (tree, data, parent = null, extraProperties, root) ->
        simpleData = tree.setting.data.simpleData
        if _.isFunction simpleData.pId
            value.pId = simpleData.pId(value) for value in data

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

    buildRootNode = (options) ->
        rootNodeSetting = options.rootNodeSetting or {}

        if options.root
            name: options.root
            isRoot: true
            checked: rootNodeSetting.checked or false
            chkDisabled: rootNodeSetting.chkDisabled or false
            halfCheck: rootNodeSetting.halfCheck or false
            icon: rootNodeSetting.icon or ''
            iconClose: rootNodeSetting.iconClose or ''
            iconOpen: rootNodeSetting.iconClose or ''
            iconSkin: rootNodeSetting.iconSkin or ''
            isParent: true
            nocheck: rootNodeSetting.nocheck or false
            target: rootNodeSetting.target or ''
            url: rootNodeSetting.url or ''
            id: options.data?.rootPId or '-1'

    normalEvents = [
        'beforeAsync', 'beforeCheck', 'beforeClick', 'beforeCollapse', 'beforeDblClick'
        'beforeExpand', 'beforeRightClick', 'onAsyncError', 'onAsyncSuccess', 'onCheck'
        'onClick', 'onCollapse', 'onDblClick', 'onExpand', 'onRightClick'
    ]
    dndEvents = ['beforeDrag', 'beforeDragOpen', 'beforeDrop', 'onDrag', 'onDrop']
    editEvents = ['beforeEditName', 'beforeRemove', 'beforeRename', 'onNodeCreated', 'onRemove', 'onRename']
    mouseEvents = ['beforeMouseDown', 'beforeMouseUp', 'onMouseDown', 'onMouseUp']

    cdeio.registerComponentHandler 'tree', (->), (el, opt, view) ->
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

        root = buildRootNode options
        if options.treeData
            if root
                resetId options.treeData, root
                tree = $.fn.zTree.init el, options, [root].concat options.treeData
            else
                tree = $.fn.zTree.init el, options, options.treeData
        else
            if options.isAsync is true
                options.callback.onExpand = (e, treeId, treeNode) ->
                    return if treeNode?['__inited__'] is true
                    treeNode and treeNode['__inited__'] = true

                    tree = $.fn.zTree.getZTreeObj treeId
                    simpleData = tree.setting.data.simpleData

                    idName = simpleData.idKey or 'id'
                    id = if treeNode is null then (if simpleData.rootPId then simpleData.rootPId else false) else treeNode[idName]
                    id = null if id is '-1'
                    filters = if id then [['eq', 'parent.id', id]] else [['null', 'parent']]
                    $.when(view.collection.fetch data: { _filters: filters }).done (data) ->
                        addTreeData tree, view.collection.toJSON(), treeNode, isParent: true

                if root
                    tree = $.fn.zTree.init el, options, [root]
                    tree.expandNode tree.getNodeByParam('id', root.id), true, false, true, true
                else
                    tree = $.fn.zTree.init el, options, []
                    options.callback.onExpand null, tree.setting.treeId, null
            else
                tree = $.fn.zTree.init el, options, []
                loadAllData view, tree, root
                if root
                    tree.expandNode root, true, false, true, true

        tree.reload = ->
            return if options.treeData

            data = $.fn.zTree._z.data
            data.initCache @setting
            data.initRoot @setting
            @setting.treeObj.empty()

            root = buildRootNode options
            if options.isAsync is true
                if root
                    tree.addNodes null, [root], true
                    tree.expandNode tree.getNodeByParam('id', root.id), true, false, true, true
                else
                    options.callback.onExpand null, tree.setting.treeId, null
            else
                loadAllData view, tree, root

                if root
                    tree.expandNode root, true, false, true, true

        bk = tree.getSelectedNodes
        tree.getSelectedNodes = ->
            nodes = bk.apply tree
            node for node in nodes when not node.isRoot

        eventHost.component = tree
        tree
