define [
    'cdeio/features/tasks.feature/views/completed-operators'
    'cdeio/features/tasks.feature/views/grid'
    'cdeio/features/tasks.feature/views/operators'
    'cdeio/features/tasks.feature/views/completed-grid'
    'cdeio/features/tasks.feature/handlers/completed-operators'
    'cdeio/features/tasks.feature/handlers/operators'
    'text!cdeio/features/tasks.feature/templates.html'
], ->

    layout:
        regions:
            operators: "operators"
            grid: "grid"
            completedOperators: "completedOperators"
            completedGrid: "completedGrid"

    views: [
        name: "operators"
        region: "operators"
    ,
        name: "grid"
        region: "grid"
    ,
        name: "completed-operators"
        region: "completedOperators"
    ,
        name: "completed-grid"
        region: "completedGrid"
    ]
    avoidLoadingModel: true
