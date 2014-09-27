define [
    'jquery'
    'underscore'
    'backbone'
    'marionette'
    'handlebars'
    'cdeio/core/config'
    'cdeio/core/util'
    'cdeio/core/resource-loader'
    'cdeio/core/loader-plugin-manager'
], ($, _, Backbone, Marionette, Handlebars, config, util, loadResource, loaderPluginManager) ->
    {log, error} = util

    class Application extends Marionette.Application
        constructor: (@options) ->
            @baseName = config.applicationName
            @paths = [config.applicationName]
            @parent = null
            @features = {}
            super

            @promises = []

        getPromises: ->
            @getApplication().promises

        addPromise: (promise) ->
            promises = @getPromises()
            idx = promises.length
            promises.push promise
            idx

        done: (fn) ->
            $.when.apply($, @getPromises()).done fn

        initRouters: ->
            deferred = $.Deferred()
            @addPromise deferred

            @loadResource(config.routerFileName).done (def) =>
                if not def
                    deferred.resolve null
                    return
                def = _.extend {}, def
                nrs = {}
                mounts = def.mounts or []
                ps = (@module(name).initRouters() for name in mounts)

                routes = def.routes
                nrs[@path name, true] = value for name, value of routes
                def.routes = nrs

                def.module = @
                Router = Backbone.Router.extend def
                @router = new Router()

                $.when.apply($, ps).done -> deferred.resolve()
            deferred.promise()

        path: (append, withoutRoot) ->
            paths = if withoutRoot is true then @paths.slice 1 else @paths
            append = if _.isArray(append) then append else [append]
            paths = paths.concat append
            paths.join '/'

        url: (append) ->
            path = @path(null, true)
            path += '/' + append if append
            prefix = config.urlPrefix
            path = if _.isFunction prefix then prefix @, path else prefix + '/' + path
            path.replace /\/{2,}/g, '/'

        # rewrite module
        module: (names) ->
            names = if _.isArray names then names else names.split '/'
            parent = @

            for name in names
                ps = [].concat parent.paths
                ps.push name

                module = parent[name] or parent[name] = new Application
                    baseName: name
                    parent: parent
                    paths: ps

                parent = module

            parent

        getApplication: ->
            if not @root
                root = @
                root = root.parent while root.parent isnt null
                @root = root
            @root

        findModule: (names) ->
            names = if _.isArray names then names else names.split '/'
            module = @
            module = module?[name] for name in names
            module

        findFeature: (name) ->
            index = name.indexOf ':'
            name = name.substring index + 1, name.length if index > 0

            for cid, feature of @features
                return feature if feature.baseName is name

        resolveResoucePath: (resourcePath) ->
            return @getApplication().path resourcePath.substring 1 if resourcePath.charAt(0) is '/'
            @path resourcePath

        # load a resource
        # resourcePath is a dot-seprated string, and it relative to current module
        # ex. :
        # module = root.module 'module.sub-module'
        # module.loadResource 'ferther-sub-module.resource-name'
        # this will load resource under `module/sub-module/ferther-sub-module/resource-name.js`
        #
        # if resourcePath starts with '/', it will use root to load it
        # module.loadResource '/module.sub-module.resource'
        loadResource: (resourcePath, plugin, useOrginalPath) ->
            return loadResource resourcePath, plugin if useOrginalPath is true
            return @getApplication().loadResource resourcePath.substring 1 if resourcePath.charAt(0) is '/'
            path = @resolveResoucePath resourcePath

            loadResource path, plugin

        loadFeature: (featurePath, options = {}) ->
            [names..., featureName] = featurePath.split '/'
            module = @findModule(names) or @module(names)

            deferred = $.Deferred()
            $.when(loaderPluginManager.invoke('feature', module, null, featureName, options)).then (feature) ->
                if feature is null
                    error module, "Feature not found at path: #{featurePath}."
                feature.deferredView.done ->
                    deferred.resolve feature

            deferred.promise()

        startFeature: (featurePath, options) ->
            deferred = $.Deferred()
            [names..., featureName] = featurePath.split '/'

            if config.disableAuthz isnt true and featurePath.indexOf('cdeio:') isnt 0 and _.indexOf(config.whitelist, featurePath) is -1
                i = featureName.indexOf(':')
                key = if i isnt -1 then featureName.substring(i + 1) else featureName
                key = names.concat([key]).join '/'
                key = key + ':show'

                if not (@settings and @settings.session and @settings.session.permissions and @settings.session.permissions[key])
                    app.error('没有操作权限')
                    console.log key
                    return deferred.reject()

            module = @findModule(names) or @module(names)
            f = module.findFeature featureName
            ignoreExists = f?.ignoreExists or options?.ignoreExists
            return f.activate(options) if f and ignoreExists isnt true

            deferred = $.Deferred()
            @addPromise deferred

            @loadFeature(featurePath, options).done (feature) =>
                feature.start().done ->
                    deferred.resolve feature
                .fail ->
                    deferred.reject feature

            deferred.promise()

        stopFeature: (feature) ->
            feature.stop()
