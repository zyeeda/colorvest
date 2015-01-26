define [
    'text!cdeio/layouts/templates/process.html'
], ->
    regions:
        tabs: 'tabs'
        toolbar_waiting: 'toolbar-waiting'
        toolbar_doing: 'toolbar-doing'
        toolbar_done: 'toolbar-done'
        toolbar_none: 'toolbar-none'

        body_waiting: 'body-waiting'
        body_doing: 'body-doing'
        body_done: 'body-done'
        body_none: 'body-none'

        filter: 'filter'

    avoidLoadingHandlers: false
    events:
        'click p-waiting': 'doWaiting'
        'click p-doing': 'doDoing'
        'click p-done': 'doDone'
        'click p-all': 'doAll'
        'click p-write': 'doWrite'

        # 'click p-*': 'tabChange'
    components: [->
        options = @feature.options.inlineGrid?.picker or @feature.startupOptions.inlineGrid?.picker
        return false unless options

        _.extend {}, options, selector: 'picker', type: 'grid-picker'
    ]

    extend:
        render: ->
            console.log @, 111