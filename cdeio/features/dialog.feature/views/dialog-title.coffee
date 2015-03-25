define
    extend:
        templateHelpers: ->
            title = @feature.startupOptions.title
            if (title.indexOf '新增') > -1
                icon = '<i class="icon-plus" style="margin-right: 5px;"></i>'
            else if (title.indexOf '查看') > -1
                icon = '<i class="icon-eye-open" style="margin-right: 5px;"></i>'
            else if (title.indexOf '编辑') > -1
                icon = '<i class="icon-edit" style="margin-right: 5px;"></i>'
            else if (title.indexOf '选择') > -1
                icon = '<i class="icon-search" style="margin-right: 5px;"></i>'

            title: title,
            icon: icon

    avoidLoadingHandlers: true

