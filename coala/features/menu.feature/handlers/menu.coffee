define ['jquery'], ($) ->
    toggleSubMenu: (e) ->
        t = $(e.target)
        el = @feature.layout.$el
        ul = undefined
        t = t.parents('a') unless t.is('a')
        ul = t.next()
        if ul.is(':visible')
            @feature._closeSubMenu ul,
                enableAnimation: true
        else
            @feature._openSubMenu ul,
                enableAnimation: true
