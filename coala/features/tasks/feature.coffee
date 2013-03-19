define [
    'coala/features/tasks/grid/feature'
    'coala/features/tasks/grid/__handlers__/grid-view'
    'coala/features/tasks/grid/__views__/grid-view'
    'coala/features/tasks/__views__/completed-operators'
    'coala/features/tasks/__views__/grid'
    'coala/features/tasks/__views__/operators'
    'coala/features/tasks/__views__/completed-grid'
    'coala/features/tasks/__handlers__/completed-operators'
    'coala/features/tasks/__handlers__/operators'

    'text!coala/features/tasks/templates.html'
    'text!coala/features/tasks/grid/templates.html'
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
