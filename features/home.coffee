define [
    'coala/features/home/__layouts__/main'
    'coala/features/home/__views__/menu'
    'text!coala/features/home/__templates__/main.html'
    'text!coala/features/home/__templates__/footer.html'
    'text!coala/features/home/__templates__/menu.html'
    'text!coala/features/home/__templates__/header.html'
], ->
    layout: "main"
    views: [
        name: "header"
        region: "north"
        avoidLoadingView: true
        avoidLoadingHandlers: true
    ,
        name: "footer"
        region: "south"
        avoidLoadingView: true
        avoidLoadingHandlers: true
    ,
        name: "menu"
        region: "west"
    ]
    avoidLoadingModel: true