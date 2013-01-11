define [
    'underscore'
], (_) ->
    LoaderPluginManager =
        pluginHandlers: {}
        key: (type, name) -> type + '#' + name
        register: (type, name = 'DEFAULT', fn) ->
            throw new Error('must specify a plugin type') if not type
            if _.isObject(type)
                @register(type.type, type.name, type.fn)
                return @
            @pluginHandlers[@key(type, name)] = fn
            @
        invoke: (type, module, feature, name, args...) ->
            throw new Error('must specify a plugin type') if not type
            if name.indexOf(':') is -1
                pluginName = 'DEFAULT'
            else
                pluginName = name.split(':')[0]
                name = name.substring(name.indexOf(':') + 1)

            fn = @pluginHandlers[@key(type, pluginName)]
            throw new Error("no plugin with type:#{type}, name: #{pluginName}") if not fn
            fn.call @, module, feature, name, args

    LoaderPluginManager
