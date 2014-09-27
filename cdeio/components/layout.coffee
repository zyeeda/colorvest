define [
    'jquery',
    'cdeio/cdeio'
    'cdeio/vendors/jquery/layout/jquery.layout'
], ($, cdeio) ->

    cdeio.registerComponentHandler 'layout', (->), (el, options, view) ->
        opts = _.extend
            view: view
        , options

        layout = el.layout opts

        layout.dispose = ->
            this.destroy()

        layout

    $.layout.callbacks =
        resizeLayout: (container) ->
            container.filter(':visible').find('.ui-layout-container:visible').andSelf().each ->
                layout = $(@).data 'layout'
                if layout
                    layout.options.resizeWithWindow = false
                    layout.resizeAll()
