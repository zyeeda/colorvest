define [
    'underscore'
    'jquery'
    'zui/coala'
    'libs/jquery/ztree/jquery.ztree.all-3.3'
], (_, $, coala) ->

    addTreeData = (tree, options, data, parent = null, obj) ->
        if _.isFunction options.data.simpleData?.pId
            value.pId = options.data.simpleData.pId(value) for value in data
            delete options.data.simpleData.pId
        (_.extend(value, obj) if obj) for value in data
        tree.addNodes parent, data, true

    coala.registerComponentHandler 'tree', (->), (el, opt, view) ->
        options = _.extend {}, opt
        delete options.async
        options.data or (options.data = {})

        simpleData = _.extend {}, options.data.simpleData
        simpleData.enable = true
        simpleData.pId = ((dataRow) -> dataRow.parent?.id) if not simpleData.pId
        options.data.simpleData = simpleData

        if options.isAsync is true
            callback = options.callback or (options.callback = {})

            beforeExpand = (treeId, d) ->
                return if d isnt null and d['__inited'] is true
                d and d['__inited'] = true

                tree = $.fn.zTree.getZTreeObj treeId
                idName = simpleData.idKey or 'id'
                id = if d is null then (if options.parentValueOfRoot then options.parentValueOfRoot else false) else d[idName]

                $.when(view.collection.fetch data: {parent: id}).done ->
                    addTreeData tree, options, view.collection.toJSON(), d, isParent: true
            callback.beforeExpand = beforeExpand

            tree = $.fn.zTree.init el, options, null
            beforeExpand tree.setting.treeId, null
            tree

        else
            if options.treeData
                $.fn.zTree.init el, options, options.treeData
            else
                tree = $.fn.zTree.init el, options, []
                $.when(view.collection.fetch()).done ->
                    data = view.collection.toJSON()
                    addTreeData tree, options, data
                tree
