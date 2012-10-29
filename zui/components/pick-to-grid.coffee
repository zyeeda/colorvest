define [
    'underscore'
    'jquery'
    'zui/coala'
], (_, $, coala) ->

    coala.registerComponentHandler 'grid-picker', (->), (el, opt = {}, view) ->
