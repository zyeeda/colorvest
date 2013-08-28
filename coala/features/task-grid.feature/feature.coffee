define [
    'coala/features/task-grid.feature/views/grid-view'
    'coala/features/task-grid.feature/handlers/grid-view'
    'text!coala/features/task-grid.feature/templates.html'
], ->
    layout: 'coala:one-region'
    views: [name: 'grid-view', region: 'main'], avoidLoadingModel: true
