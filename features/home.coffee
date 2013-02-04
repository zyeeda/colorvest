define [
    'coala/features/home/__layouts__/main'
    'text!coala/features/home/__templates__/main.html'
    'text!coala/features/home/__templates__/header.html'
    'text!coala/features/home/__templates__/footer.html'
    'text!coala/features/home/__templates__/content.html'
], ->
    layout: 'main'
    avoidLoadingModel: true
    avoidLoadingHandlers: true
    views: [
        name: 'header'
        region: 'header'
        avoidLoadingHandlers: true
    ,
        name: 'content'
        region: 'content'
    ]
