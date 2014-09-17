define [
    'jquery'
    'underscore'
    'cdeio/cdeio'
    'cdeio/vendors/jquery/ui/tabs'
], ($, _, cdeio) ->

    cdeio.registerComponentHandler 'tabs', (->), (el, options, view) ->
        tabs = el.tabs options

        tabs.dispose = ->
            @tabs 'destroy'

        tabs
