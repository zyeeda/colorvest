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
            multiple: true
            columns: [
                name: "id", header: "ID"
            ,
                name: "name", header: "Name"
            ,
                name: "createTime", header: "Create Time"
            ,
                name: "assignee", header: "Assignee"
            ]

        if @feature.startupOptions.option?.toDoColumns
            o.columns = @feature.startupOptions.option.toDoColumns

        for c in o.columns
            c.sortable = !!sortable[c.name]
        o
    ]
    avoidLoadingHandlers: true
