define ->
    sortable = {
        id: true
        processInstanceId: true
        processDefinitionId: true
        startTime: true
        endTime: true
        durationInMillis: true
        deleteReason: true
        endActivityId: true
        businessKey: true
        startUserId: true
        startActivityId: true
        superProcessInstanceId: true
    }

    path: "completed"
    components: [ ->
        o =
            type: "grid"
            selector: "grid"
            pager: "pager"
            fit: true
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
                name: 'durationInMillis'
            ]

        if @feature.startupOptions.option?.finishedColModel
            o.colModel = @feature.startupOptions.option.finishedColModel

        for c in o.colModel
            c.sortable = !!sortable[c.name]

        o
    ]
    avoidLoadingHandlers: true
    avoidLoadingModel: true
