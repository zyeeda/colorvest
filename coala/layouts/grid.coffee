define [
    'text!coala/layouts/templates/grid.html'
], ->
    regions:
        toolbar: 'toolbar'
        body: 'body'
        filter: 'filter'

    avoidLoadingHandlers: false
    events:
        'click ok': 'doFilter'
        'click reset': 'doReset'
