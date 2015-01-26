define [
    'underscore'
    'jquery'
    'bootstrap'
    'cdeio/features/dialog.feature/views/dialog-title'
    'cdeio/features/dialog.feature/views/dialog-buttons'
    'text!cdeio/features/dialog.feature/templates.html'
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

    