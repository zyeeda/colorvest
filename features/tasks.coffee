define [
    'coala/features/tasks/routers'
    'coala/features/tasks/grid'
    'coala/features/tasks/__handlers__/completed-operators'
    'coala/features/tasks/__handlers__/operators'
    'coala/features/tasks/grid/__handlers__/grid-view'
    'coala/features/tasks/grid/__layouts__/grid'
    'coala/features/tasks/grid/__views__/grid-view'
    'coala/features/tasks/__layouts__/tasks'
    'coala/features/tasks/__views__/completed-operators'
    'coala/features/tasks/__views__/grid'
    'coala/features/tasks/__views__/operators'
    'coala/features/tasks/__views__/completed-grid'

    'text!coala/features/tasks/__templates__/tasks.html'
    'text!coala/features/tasks/__templates__/operators.html'
    'text!coala/features/tasks/__templates__/completed-operators.html'
    'text!coala/features/tasks/__templates__/grid.html'
    'text!coala/features/tasks/__templates__/completed-grid.html'
    'text!coala/features/tasks/grid/__templates__/grid-view.html'
    'text!coala/features/tasks/grid/__templates__/grid.html'
], ->
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