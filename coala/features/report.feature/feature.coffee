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
            toolbar: "report-toolbar"
            body: "report-body"

    views: [
        {name: 'report-body', region: 'body'},
        {name: 'report-toolbar', region: 'toolbar'}
    ]    

    avoidLoadingModel: true