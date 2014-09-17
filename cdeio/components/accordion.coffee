define [
    'underscore'
    'cdeio/cdeio'
    'cdeio/vendors/jquery/ui/accordion'
], (_, cdeio) ->

    cdeio.registerComponentHandler 'accordion', (->), (el, options, view) ->
        accordion = el.accordion options

        accordion.dispose = ->
            @accordion 'destroy'

        accordion
