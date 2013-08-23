define [
    'coala/features/tasks.feature/views/completed-operators'
    'coala/features/tasks.feature/views/grid'
    'coala/features/tasks.feature/views/operators'
    'coala/features/tasks.feature/views/completed-grid'
    'coala/features/tasks.feature/handlers/completed-operators'
    'coala/features/tasks.feature/handlers/operators'
    'text!coala/features/tasks.feature/templates.html'
    'text!coala/features/tasks.feature/grid/templates.html'
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
