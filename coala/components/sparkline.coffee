define [
    'underscore'
    'coala/coala'
    'coala/vendors/jquery/jquery.sparkline.min'
], (_, coala) ->

    coala.registerComponentHandler 'sparkline', (->), (el, options, view) ->
        $box = el.closest '.infobox'
        barColor = unless $box.hasClass('infobox-dark') then $box.css('color') else '#FFF'
        opt = _.extend
            tagValuesAttribute:'data-values'
            type: 'bar'
            barColor: barColor
            chartRangeMin: el.data('min') || 0
        , options
        data = opt.data or 'html'

        el.sparkline data, opt
