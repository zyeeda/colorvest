define [
    'underscore'
    'cdeio/cdeio'
    'cdeio/vendors/jquery/jquery.easy-pie-chart.min'
], (_, cdeio) ->

    cdeio.registerComponentHandler 'easy-pie', (->), (el, options, view) ->
        $box = el.closest '.infobox'
        barColor = el.data('color') or (unless $box.hasClass('infobox-dark') then $box.css('color') else 'rgba(255,255,255,0.95)')
        trackColor = if barColor == 'rgba(255,255,255,0.95)' then 'rgba(255,255,255,0.25)' else '#E2E2E2'
        size = parseInt(el.data 'size' ) || 50
        oldie = $.browser.msie and $.browser.version < 9

        opt = _.extend
            barColor: barColor
            trackColor: trackColor
            scaleColor: false
            lineCap: 'butt'
            lineWidth: parseInt(size/10)
            animate: if oldie then false else 1000
            size: size
        , options
        el.css 'color', barColor

        el.easyPieChart opt
