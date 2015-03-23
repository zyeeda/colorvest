define
    extend:
        templateHelpers: ->
            title = @feature.startupOptions.title
            # console.log title
            # tilteOfAdd = true if title.contains '新增'
            # tilteOfShow = true if title.contains '查看'
            # tilteOfEdit = true if title.contains '编辑'
            # tilteOfRemove = true if title.contains '删除'
            # tilteOfAdd: tilteOfAdd,
            # tilteOfShow: tilteOfShow,
            # tilteOfEdit: tilteOfEdit,
            # tilteOfRemove: tilteOfRemove
            title: title

    avoidLoadingHandlers: true

