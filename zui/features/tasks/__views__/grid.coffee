define ->
    sortable = {
        id: true, name: true, description: true, priority: true, owner: true,
        assignee: true, processInstanceId: true, processDefinitionId: true,
        createTime: true, dueDate: true, startTime: true, endTime: true
    }

    components: [ ->
        o =
            type: "grid"
            selector: "grid"
            pager: "pager"
            multiselect: true
            colModel: [
                name: "id"
                label: "ID"
            ,
                name: "name"
                label: "Name"
            ,
                name: "createTime"
                label: "Create Time"
            ,
                name: "assignee"
                label: "Assignee"
            ]

        if @feature.startupOptions.option?.toDoColModel
            o.colModel = @feature.startupOptions.option.toDoColModel

        for c in o.colModel
            c.sortable = !!sortable[c.name]
        o
    ]
    avoidLoadingHandlers: true
