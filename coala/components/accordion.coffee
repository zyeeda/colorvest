define [
    'underscore'
    'coala/coala'
    'coala/vendors/jquery/ui/accordion'
], (_, coala) ->

    coala.registerComponentHandler 'accordion', (->), (el, options, view) ->
        el.accordion options
