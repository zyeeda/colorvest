define [
    'underscore'
    'coala/coala'
    'coala/vendors/jquery/jquery.maskedinput'
], (_, coala) ->

    coala.registerComponentHandler 'mask', (->), (el, options, view) ->
        pattern = options.pattern or ''
        el.mask pattern, options
