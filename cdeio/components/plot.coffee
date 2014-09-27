define [
    'underscore'
    'cdeio/cdeio'
    'cdeio/vendors/jquery/flot/jquery.flot.min'
    'cdeio/vendors/jquery/flot/jquery.flot.pie.min'
    'cdeio/vendors/jquery/flot/jquery.flot.resize.min'
], (_, cdeio) ->

    cdeio.registerComponentHandler 'plot', (->), (el, options, view) ->
        $.plot el, options.data, options
