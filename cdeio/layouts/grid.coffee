define [
    'text!cdeio/layouts/templates/grid.html'
], ->
    regions:
        toolbar: 'toolbar'
        body: 'body'

    avoidLoadingHandlers: false
    events:
        'click ok': 'doFilter'
        'click reset': 'doReset'

    components: [->
        options = @feature.options.inlineGrid?.picker or @feature.startupOptions.inlineGrid?.picker
        return false unless options

        _.extend {}, options, selector: 'picker', type: 'grid-picker'
    ]
