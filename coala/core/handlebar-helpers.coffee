define ['handlebars', 'underscore'], (H, _) ->

    H.registerHelper 'appearFalse', (value) -> if value is false then 'false' else value

    H.registerHelper 'view', (value, options) ->
        if @['__viewName__'] is value and not @['__layout__']
            options.fn @
        else
            ''

    H.registerHelper 'layout', (value, options) ->
        if _.isFunction value
            if @['__layout__'] is true then value @ else ''
        else
            if @['__layout__'] is true and @['__viewName__'] is value
                options.fn @
            else
                ''
    H
