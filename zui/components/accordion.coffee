
define [
    'underscore'
    'zui/coala'
    'jqueryui/accordion'
], (_, coala) ->

    coala.registerComponentHandler 'accordion', (->), (el, options, view) ->
        el.accordion options
