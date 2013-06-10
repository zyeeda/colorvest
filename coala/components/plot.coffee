define [
    'underscore'
    'coala/coala'
    'coala/vendors/jquery/flot/jquery.flot.min'
    'coala/vendors/jquery/flot/jquery.flot.pie.min'
    'coala/vendors/jquery/flot/jquery.flot.resize.min'
], (_, coala) ->

    coala.registerComponentHandler 'plot', (->), (el, options, view) ->
        $.plot el, options.data, options
