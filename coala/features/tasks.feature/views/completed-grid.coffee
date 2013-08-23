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
            columns: [
                name: "id", header: "ID"
            ,
                name: "name", header: "Name"
            ,
                name: "startTime", header: "Start Time"
            ,
                name: 'durationInMillis', header: 'Duration In Millis'
            ]

        if @feature.startupOptions.option?.finishedColumns
            o.columns = @feature.startupOptions.option.finishedColumns

        for c in o.columns
            c.sortable = !!sortable[c.name]

        o
    ]
    avoidLoadingHandlers: true
    avoidLoadingModel: true
