define [
    'underscore'
    'cdeio/cdeio'
    'cdeio/vendors/jquery/jquery.maskedinput'
], (_, cdeio) ->

    cdeio.registerComponentHandler 'mask', (->), (el, options, view) ->
        pattern = options.pattern or ''
        el.mask pattern, options
