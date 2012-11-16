define [
    'jquery'
    'underscore'
    'backbone'
    'marionette'
    'handlebars'
    'zui/coala/config'
    'zui/coala/util'
    'zui/coala/resource-loader'
    'zui/coala/loader-plugin-manager'
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
            @initRouters()

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
            idx = @addPromise(@loadResource config.routerFileName)

            @done _.bind (index, args...) ->
                def = args[index]
                return if not def
                def = _.extend {}, def
                nrs = {}
                routes = def.routes
                nrs[@path name, true] = value for name, value of routes
                def.routes = nrs

                def.module = @
                Router = Backbone.Router.extend def
                @router = new Router()
            , @, idx

        path: (append, withoutRoot) ->
            paths = if withoutRoot is true then @paths.slice 1 else @paths
            append = if _.isArray(append) then append else [append]
            paths = paths.concat append
            paths.join '/'

        url: (append) ->
            prefix = config.urlPrefix
            prefix = if _.isFunction prefix then prefix @ else prefix
            path = prefix + '/' + @path(null, true)
            path += '/' + append if append
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

        startFeature: (featurePath, options) ->
            [names..., featureName] = featurePath.split '/'
            module = @findModule(names) or @module(names)
            f = module.findFeature featureName
            ignoreExists = f?.ignoreExists or options?.ignoreExists
            return f.activate(options) if f and ignoreExists isnt true

            deferred = $.Deferred()
            module.addPromise deferred

            $.when(loaderPluginManager.invoke('feature', module, null, featureName, options)).then (feature) ->
                if feature is null
                    log module, "feature not found with path: #{featurePath}"
                    deferred.resolve null
                    return module.startFeature('notfound:' + featureName, options)

                module.features[feature.cid] = feature
                feature.start().done ->
                    deferred.resolve feature
            deferred

        stopFeature: (feature) ->
            feature.stop()
            delete feature.module.features[feature.cid]
