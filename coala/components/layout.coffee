define [
    'jquery',
    'coala/vendors/jquery/layout/jquery.layout'
], ($) ->

    $.layout.callbacks =

        resizeLayout: (container) ->
            container.filter(':visible').find('.ui-layout-container:visible').andSelf().each ->
                layout = $(@).data 'layout'
                if layout
                    layout.options.resizeWithWindow = false
                    layout.resizeAll()
