define ['handlebars', 'underscore'], (H, _) ->

    H.registerHelper 'appearFalse', (value) -> if value is false then 'false' else value

    H.registerHelper 'perm', (value, options) ->
        return options.fn @ if not @['__view__']
        feature = @['__view__'].feature
        if feature.isPermitted value then options.fn() else options.inverse()

    H.registerHelper 'auth', (value, options) ->
        return options.fn @ if not @['__view__']
        app = @['__view__'].feature.module.getApplication()
        if app.settings?.session?.authenticated then options.fn() else options.inverse()

    H.registerHelper 'user', (value, options) ->
        return options.fn @ if not @['__view__']
        app = @['__view__'].feature.module.getApplication()
        if app.settings?.session then options.fn() else options.inverse()

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
