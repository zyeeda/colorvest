define ["zui/coala/view", "underscore"], (View, _) ->
    showPicker: ->
        options = @feature.startupOptions
        me = this
        treeOptions = _.extend(options.tree or {},
            type: "tree"
            selector: "tree"
            check:
                enable: true
                chkStyle: "radio"
                radioType: "all"

            data:
                simpleData:
                    enable: true
        )
        view = new View(
            baseName: "tree-picker-tree-view"
            feature: @feature
            module: @module
            model: options.url
            components: [treeOptions]
            avoidLoadingHandlers: true
        )
        app = @feature.module.getApplication()
        root = app.applicationRoot
        root.showDialog
            title: options.title
            view: view
            buttons: [
                label: "OK"
                fn: ->
                    tree = view.components[0]
                    selected = tree.getCheckedNodes()
                    return false  if selected.length is 0
                    rowData = selected[0]
                    text = (options.toText or (data) ->
                        data.name
                    )(rowData)
                    me.$("text").val text
                    options.valueField.val rowData["id"]
                    true
            ]


