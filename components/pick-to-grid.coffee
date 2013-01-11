define [
    'underscore'
    'jquery'
    'coala/coala'
], (_, $, coala) ->

    coala.registerComponentHandler 'grid-picker', (->), (el, opt = {}, view) ->
