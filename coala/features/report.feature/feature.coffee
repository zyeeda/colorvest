define [
    'underscore'
    'jquery'
    'bootstrap'
    'coala/features/dialog.feature/views/dialog-title'
    'coala/features/dialog.feature/views/dialog-buttons'
    'text!coala/features/dialog.feature/templates.html'
], (_, $) ->
    layout:
        regions:
            body: "report-body"

    views: [
        name: 'report-body'
        region: 'body'
    ]

    avoidLoadingModel: true