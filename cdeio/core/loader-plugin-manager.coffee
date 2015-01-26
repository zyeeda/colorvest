define [
    'underscore'
], (_) ->
    LoaderPluginManager =

        pluginHandlers: {}

        key: (type, name) -> type + '#' + name

        register: (type, name = 'DEFAULT', fn) ->
            throw new Error('Must specify a plugin type.') if not type

            if _.isObject type
                @register type.type, type.name, type.fn
                return @
            @pluginHandlers[@key type, name] = fn
            @

        invoke: (type, module, feature, name, args...) ->
            throw new Error('Must specify a plugin type.') if not type

            if _.isObject name
                args.unshift name
                name = name.name or ''

            if name.indexOf(':') is -1
                pluginName = 'DEFAULT'
            else
                # Variable name may contain other ':' seperator.
                #[pluginName, name] = name.split ':'
                pluginName = name.split(':')[0]
                name = name.substring(name.indexOf(':') + 1)

            fn = @pluginHandlers[@key type, pluginName]
            throw new Error("No plugin with key #{type}##{pluginName}.") if not fn
            fn.call @, module, feature, name, args

    LoaderPluginManager
