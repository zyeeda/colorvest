define minMenu: ->
    el = @feature.layout.$el
    el.toggleClass 'menu-min'
    @$('btn').toggleClass 'icon-double-angle-right'
    if el.hasClass('menu-min')
        $('.open > .submenu').removeClass 'open'
