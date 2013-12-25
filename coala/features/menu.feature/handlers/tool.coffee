define minMenu: ->
    el = @feature.layout.$el
    el.toggleClass 'menu-min'
    @$('btn').toggleClass 'icon-double-angle-right'
    if el.hasClass('menu-min')
        console.log 'aa'
        $('.open > .submenu').removeClass 'open'
