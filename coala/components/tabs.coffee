define [
    'jquery'
    'underscore'
    'coala/coala'
    'coala/vendors/jquery/ui/tabs'
], ($, _, coala) ->

    coala.registerComponentHandler 'tabs', (->), (el, options, view) ->
        tabs = el.tabs options

        tabs.dispose = ->
            @tabs 'destroy'

        tabs
