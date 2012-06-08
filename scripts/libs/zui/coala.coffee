getBaseName = (base) ->
    str = []
    str.push "[#{base.baseName}]"
    if base.path
        str.push "[#{base.path()}]"
    else if base.module and base.feature
        str.push "[#{base.module.path(base.feature.baseName)}]"
    else if base.module
        str.push "[#{base.module.path()}]"
    str.join ' under '

log = (base, messages...) ->
    return if not console
    messages.unshift getBaseName base
    console.log.apply console, messages

error = (base, messages...) ->
    messages.unshift getBaseName base
    throw new Error(messages.join ' ')

_define = ($, _, Backbone, Marionette, Handlebars, loadResource) ->

    # override marionette's template loader
    Marionette.TemplateCache.loadTemplate = (templateId, callback) ->
        loadResource(templateId, 'text').done (template) ->
            tpl = Handlebars.compile template or ''
            callback.call @, tpl

    coala =
        applicationName: 'app'
        templateSuffix: '.html'
        featureContainer: 'body'
        urlPrefix: 'invoke/'
        modelDefinitionPath: 'definition'

        folders:
            layout: 'layouts/'
            view: 'views/'
            model: 'models/'
            collection: 'collections/'
            handler: 'handlers/'
            template: 'templates/'

    coala.ComponentHandler =
        initializers: []
        handlers: {}
        promises: []
        regist: (name, initializer, handler) ->
            initializer = _.bind (path)->
                @promises.push loadResource path
            , @, initializer if _.isString initializer

            @initializers.push initializer
            @handlers[name] = handler
            @
        initialize: ->
            promises = []
            promises.push initializer() for initializer in @initializers
            @deferred = $.when.apply($, @promises)
        done: (fn) ->
            @initialize() if not @deferred
            @deferred.done fn
        defaultHandler: (name, $el, options) ->
            $el[name] options if $el[name]
        handle: (name, $el, options = {}) ->
            handler = @handlers[name]
            if handler then handler($el, options) else @defaultHandler(name, $el, options)


    getPath = (type, path) ->
        root = true if path.charAt(0) is '/'
        path = path.substring 1 if root is true

        (if root then '/' else '') + coala.folders[type] + path

    Sync =
        methodMap:
            'create': 'POST'
            'update': 'PUT'
            'delete': 'DELETE'
            'read': 'GET'
        fn: (method, model, options = {}) ->
            type = Sync.methodMap[method]

            params = type: type, dataType: 'json', url: model.url()
            params.data = _.extend model.toJSON(), options.data or {}
            delete options.data

            $.ajax _.extend params, options

    Backbone.sync = Sync.fn

    class coala.BaseView extends Marionette.ItemView
        constructor: (options) ->
            @promises or= []
            @module = options.module
            @feature = options.feature
            @baseName = options.baseName
            super options
            @promises.push @initHandlers(options.handlersIn)

        initialize: (options) ->
            @events = options.events
            for name, value of options.events or {}
                if not _.isFunction value
                    @events[name] = _.bind (n, args...) ->
                        method = @eventHandlers[n]
                        error @, "no handler named #{value}" if not method
                        method.apply @, args
                    , @, value

        initHandlers: (handler) ->
            path = getPath('handler', handler or @baseName)
            @module.loadResource(path).done (handlers = {}) =>
                @eventHandlers = handlers

        template: ->
            getPath 'template', @baseName

        getTemplateSelector: ->
            template = @template or @options.template
            if _.isFunction template
                template = template.call this
            @module.resolveResoucePath template + coala.templateSuffix

        afterRender: ->
            @options.afterRender.call @ if _.isFunction @options.afterRender

        render: (fn)->
            $.when.apply($, @promises).then =>
                super.done fn

        onRender: ->
            components = []
            evalComponent = (view, $el, options) ->
                {type, selector} = options

                delete options.type
                delete options.selector

                el = if selector then view.$ selector else $el
                components.push coala.ComponentHandler.handle(type, el, options)
            evalAction = (view, $el, options) ->
                {action, selector} = options

                delete options.action
                delete options.selector

                el = if selector then view.$ selector else $el
                el[action]?.call el, options
            for name, value of @options.components
                $el = @$ name
                if _.isString value
                    value = if coala.ComponentHandler.handlers[value] then type: value else action: value
                (if value.type then evalComponent else evalAction) @, @$el, value
            @components = components

            @afterRender.call @
            return

    class coala.View extends coala.BaseView
        constructor: (options) ->
            @baseName = options.baseName
            @feature = options.feature
            @module = options.module
            @model = options.model
            @options = options
            super options

            @deferredModel = @initModel()
            @deferredCollection = @initCollection()
            @promises?.push @deferredModel
            @promises?.push @deferredCollection

        url: ->
            @feature.url() + '/' + @baseName

        initModel: ->
            return if @model
            deferred = $.Deferred()
            if not @options.path
                @model = @feature.model
                @collection = @feature.collection
                deferred.resolve()
                return deferred

            @module.loadResource(getPath 'model', @options.path).done (def) =>
                if not def
                    @module.loadResource(@url() + '/' + @options.path + '/' + coala.modelDefinitionPath, null, true).done (data) =>
                        if data
                            data.feature = @feature
                            data.path = @options.path
                            @modelDefinition = coala.Model.extend data
                            @model = new @modelDefinition()
                            deferred.resolve()
                        else
                            @modelDefinition = coala.Model.extend feature: @feature, path: @options.path
                            @model = new @modelDefinition()
                            deferred.resolve()
                else
                    def.feature = @feature
                    def.path = @options.path
                    @modelDefinition = coala.Model.extend def
                    @model = new @modelDefinition()
                    deferred.resolve()
            deferred

        initCollection: ->
            return if @collection
            @deferredModel.done =>
                @collection = new (coala.Collection.extend feature: @feature)(null, model: @modelDefinition)

    class coala.Layout extends coala.BaseView
        constructor: (options)->
            @vent = new Marionette.EventAggregator()
            @regions = options.regions or {}
            super options
            @regionManagers = {}

        template: ->
            getPath('template', @baseName)

        render: ->
            @initializeRegions()
            super

        initializeRegions: Marionette.Layout.prototype.initializeRegions
        closeRegions: Marionette.Layout.prototype.closeRegions
        close: Marionette.Layout.prototype.close


    class coala.Model extends Backbone.Model
        url: ->
            path = @path
            url = @view?.url() or @feature?.url() or ''
            if path then url + '/' + path else url

    class coala.Collection extends Backbone.Collection
        url: ->
            path = @path
            url = @view?.url() or @feature?.url() or ''
            if path then url + '/' + path else url

    class coala.Feature
        constructor: (@options) ->
            @cid = _.uniqueId 'feature'
            @baseName = options.baseName
            @module = options.module
            @model = options.model if options.model
            @collection = options.collection if options.collection

            @initRenderTarget()
            @deferredLayout = @initLayout()
            @deferredModel = @initModel()
            @deferredCollection = @initCollection()
            @deferredView = @initViews()

        initRenderTarget: ->
            target = @options.target or coala.featureContainer
            target = target @ if _.isFunction target
            # in this case, target must be a selector or dom element or $element
            @container = target

        initLayout: ->
            layout = @options.layout
            error @, 'no layout defined' if not layout

            @module.getRoot().loadResource(getPath 'layout', layout).done (def) =>
                error @, 'no layout defined with name:', @module.getRoot().path(layout) if not def
                def.el = @container
                def.baseName = layout
                def.feature = @
                def.module = @module
                @layout = new coala.Layout def

        initModel: ->
            return if @model
            deferred = $.Deferred()
            @module.loadResource(getPath 'model', @baseName).done (def) =>
                if not def
                    @module.loadResource(@url() + '/' + coala.modelDefinitionPath, null, true).done (data) =>
                        if data
                            @modelDefinition = coala.Model.extend data
                            @model = new @modelDefinition()
                            deferred.resolve()
                        else
                            @modelDefinition = coala.Model.extend feature: @
                            @model = new @modelDefinition()
                            deferred.resolve()
                else
                    def.feature = @
                    @modelDefinition = coala.Model.extend def
                    @model = new @modelDefinition()
                    deferred.resolve()
            deferred.promise()

        initCollection: ->
            return if @collection
            @deferredModel.done =>
                @collection = new (coala.Collection.extend feature: @)(null, model: @modelDefinition)

        initViews: () ->
            @inRegionViews = {}
            @views = {}

            views = []
            promises = [@deferredLayout,@deferredModel]
            for view in @options.views or []
                view = if _.isString(view) then name: view else view
                views.push view
                promises.push @module.loadResource getPath 'view', view.name

            defered = $.when.apply($, promises).then _.bind (vs, u1,u2, args...) =>
                for options, i in args
                    options or= {}
                    options.baseName = vs[i].name
                    options.feature = @
                    options.module = @module
                    @views[i] = @views[vs[i].name] = new coala.View options
                    @inRegionViews[vs[i].region] = @views[i] if vs[i].region
                return
            , @, views
            defered.promise()

        showView: (region, view) ->
            view = @inRegionViews[region] if not view
            view = @views[index] if _.isNumber view
            return if not view

            promise = if @deferredStart then @deferredStart.promise() else @start()

            promise.done =>
                @layout[region].show view

        url: ->
            prefix = coala.urlPrefix
            prefix = if _.isFunction prefix then prefix @ else prefix
            path = @module.path @baseName, true

            prefix + path

        # delegate $.ajax, do nothing but add url prefix
        request:  (options) ->
            options.url = @url() + '/' + options.url
            $.ajax options

        active: ->
            #override this

        start: ->
            @deferredStart = $.Deferred()
            views = []
            rendered = {}
            @deferredView.done =>
                @layout.render =>
                    for region, view of @inRegionViews
                        views.push region
                        view.on 'show', _.once _.bind( (rr, vs, rd)->
                            rd[rr] = true
                            if _.all(vs, (r) -> !!rd[r])
                                @deferredStart.resolve @
                        , @, region, views, rendered)
                        @layout[region].show view
            @deferredStart.promise()


    class coala.Application extends Marionette.Application
        baseName: coala.applicationName
        paths: [coala.applicationName]
        parent: null
        features: {}

        path: (append, withoutRoot) ->
            paths = if withoutRoot is true then @paths.slice 1 else @paths
            append = if _.isArray(append) then append else [append]
            paths = paths.concat append
            paths.join '/'

        # rewrite module
        module: (names) ->
            names = if _.isArray names then names else names.split '/'
            parent = @

            for name in names
                module = parent[name] or parent[name] = new coala.Application()
                module.baseName = name
                module.parent = parent
                module.paths = [].concat parent.paths
                module.paths.push name
                module.features = {}

                parent = module

            parent

        getRoot: ->
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
            return @getRoot().path resourcePath.substring 1 if resourcePath.charAt(0) is '/'
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
        loadResource: (resourcePath, plugin, dontProcessPath) ->
            return loadResource resourcePath, plugin if dontProcessPath is true
            return @getRoot().loadResource resourcePath.substring 1 if resourcePath.charAt(0) is '/'
            path = @resolveResoucePath resourcePath

            #log @, 'load resource:', resourcePath, ' in path:', path
            loadResource path, plugin

        startFeature: (featurePath, container) ->
            [names..., featureName] = featurePath.split '/'
            module = @findModule(names) or @module(names)
            f = module.findFeature featureName
            return f.active() if f and not container

            deferred = $.Deferred()

            @loadResource(featurePath).done _.bind (mod, def) ->
                def.baseName = featureName
                def.module = mod
                def.container = container if container?

                feature = new coala.Feature def
                mod.features[feature.cid] = feature

                feature.start().done ->
                    deferred.resolve feature
            , @, module
            deferred.promise();
        stopFeature: (feature) ->
            delete feature.module.features[feature.cid]
    coala

if define? and define.amd?

    # handle 'timeout' error
    defaultHandler = require.onError

    require.onError = (err) ->
        if err.requireType is 'timeout'
            log baseName: 'NOTFOUND', "timeout when load modules:#{err.requireModules}"
            for name in err.requireModules.split ' '
                require.s.contexts._.completeLoad name
        else
            defaultHandler.call require, err

    define ['require', 'jquery','underscore', 'backbone', 'marionette', 'handlebars'], \
    (require, $, _, Backbone, Marionette, Handlebars) ->
        resourceLoader = (resource, plugin) ->
            deferred = $.Deferred()
            path = if plugin then plugin + '!' + resource else resource

            log baseName: 'resource loader', 'load path:', path

            require [path], _.bind (path, result) ->
                deferred.resolve result
            , @, path
            deferred.promise()

        _define $, _, Backbone, Marionette, Handlebars, resourceLoader
else

    resourceLoader = (resource, plugin) ->
        options = {url: resource}
        options.dataType = plugin if plugin
        $.ajax options

    scriptLoader = (modules) ->
        # not implement yet.

    _define $, _, Backbone, Marionette, Handlebars, resourceLoader
