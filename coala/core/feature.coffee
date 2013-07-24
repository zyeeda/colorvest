define [
    'jquery'
    'underscore'
    'marionette'
    'coala/core/config'
    'coala/core/util'
    'coala/core/model'
    'coala/core/collection'
    'coala/core/layout'
    'coala/core/loader-plugin-manager'
], ($, _, M, config, util, Model, Collection, Layout, loaderPluginManager) ->
    {getPath} = config
    {log, error} = util

    class Feature
        constructor: (@options, @startupOptions = {}) ->
            options.avoidLoadingModel = if options.avoidLoadingModel is false then false else true
            @cid = _.uniqueId 'feature'
            @baseName = options.baseName
            @module = options.module
            @model = options.model if options.model
            @collection = options.collection if options.collection
            @module.features[@cid] = @

            if @options.extend
                for key, value of @options.extend
                    old = @[key]
                    if _.isFunction value
                        value = _.bind value, @, old
                    @[key] = value

            @initRenderTarget()
            @deferredTemplate = @initTemplate()
            @deferredLayout = @initLayout()
            @deferredModel = @initModel()
            @deferredCollection = @initCollection()
            @deferredView = @initViews()

        initRenderTarget: ->
            target = @container or @options.container or @startupOptions.container or config.featureContainer
            target = target @ if _.isFunction target
            # in this case, target must be a selector or dom element or $element
            @container = target

        initTemplate: ->
            return null if @options.avoidLoadingTemplate is true
            M.TemplateCache.get(@module.resolveResoucePath(@baseName + '.feature/templates' + config.templateSuffix)).done (template) =>
                @template = template

        initLayout: ->
            layout = @options.layout
            layout = @baseName if not layout

            loaderPluginManager.invoke('layout', @module, @, layout).done (layout) =>
                @layout = layout

        initModel: ->
            return if @model
            deferred = $.Deferred()

            if @options.avoidLoadingModel is true
                @ModelDefinition = Model.extend feature: @
                @model = new @ModelDefinition()
                deferred.resolve()
                return deferred.promise()

            @module.loadResource(getPath @, 'model', @baseName).done (def) =>
                if not def
                    @ModelDefinition = Model.extend feature: @
                    @model = new @ModelDefinition()
                    deferred.resolve()
                else
                    def.feature = @
                    @ModelDefinition = Model.extend def
                    @model = new @ModelDefinition()
                    deferred.resolve()
            deferred.promise()

        initCollection: ->
            return if @collection
            @deferredModel.done =>
                @collection = new (Collection.extend feature: @)(null, model: @ModelDefinition)

        initViews: () ->
            @inRegionViews = {}
            @views = {}

            views = []
            promises = [@deferredTemplate, @deferredLayout, @deferredModel]
            for view in @options.views or []
                view = if _.isString view then name: view else view
                views.push view
                promises.push loaderPluginManager.invoke 'view', @module, @, view

            deferred = $.when.apply($, promises).then _.bind (vs, u1, u2, u3, args...) =>
                for v, i in args
                    @views[i] = @views[vs[i].name] = v
                    @inRegionViews[vs[i].region] = @views[i] if vs[i].region
                return
            , @, views
            deferred.promise()

        showView: (region, view) ->
            deferred = $.Deferred()
            view = @inRegionViews[region] if not view
            view = @views[view] if _.isNumber view
            return if not view

            promise = if @deferredStart then @deferredStart.promise() else @start()

            if @layout[region].currentView?.cid is view.cid
                deferred.resolve()
            else
                view.on 'show', _.once ->
                    deferred.resolve()
                promise.done =>
                    @layout[region].show view

            deferred.promise()

        url: ->
            @module.url(@baseName)

        path: ->
            @module.path(@baseName, true)

        # delegate $.ajax, do nothing but add url prefix
        request: (options) ->
            options.url = @url() + '/' + options.url
            $.ajax options

        # Specific feature should override this method to implement other activation behavior.
        activate: (options) ->
            @startupOptions = options
            @start()

        onStop: ->

        stop: ->
            @deferredStop = $.Deferred()
            result = @onStop()
            resolve = (r) =>
                if r isnt false
                    delete @module.features[@cid]
                    @deferredStop.resolve @
                else
                    @deferredStop.reject @

            if result and _.isFunction result.done
                result.done (arg) ->
                    resolve arg
            else
                resolve result

            @deferredStop.promise()

        onStart: ->

        start: ->
            @deferredStart = $.Deferred()

            callOnStart = =>
                console.log 'call on start'
                result = @onStart()

                if result and _.isFunction result.done
                    result.done => @deferredStart.resolve @
                else
                    if result is false
                        @deferredStart.reject @
                    else
                        @deferredStart.resolve @

            fn = =>
                views = []
                rendered = {}
                @deferredView.done =>
                    console.log 'deferred view done'
                    @layout.render =>
                        console.log 'aaa'
                        views.push region for region, view of @inRegionViews
                        console.log 'bbb'
                        if views.length is 0
                            console.log 'ccc'
                            callOnStart()
                            return

                        for region, view of @inRegionViews
                            console.log 'ddd'
                            view.on 'show', _.once _.bind (rr, vs, rd) ->
                                console.log 'eee'
                                rd[rr] = true
                                callOnStart() if _.all vs, (r) -> !!rd[r]
                            , @, region, views, rendered
                            console.log 'fff'
                            @layout[region].show view
                            console.log 'ggg'

            console.log '111'
            c = $ @container
            console.log '222'
            old = c.data 'feature'
            console.log '333'
            if old and old.cid isnt @cid
                console.log '444'
                old.stop().done =>
                    console.log '555'
                    c.data 'feature', @
                    console.log '666'
                    fn()
                    console.log '777'
                .fail =>
                    console.log '888'
                    @deferredStart.reject @
            else
                console.log '999'
                c.data 'feature', @
                console.log '000'
                fn()
                console.log '1111'

            @deferredStart.promise()

        genEventName: (eventName) ->
            @path() + '#' + eventName

        isFeatureEvent: (eventName) ->
            eventName.indexOf('#') isnt -1

        on: (eventName, callback, context) ->
            if eventName.indexOf('#') is -1
                name = @genEventName eventName
            else
                name = if eventName.indexOf('this#') isnt -1 then @genEventName(eventName.split('#')[1]) else eventName
            @module.getApplication().vent.on name, callback, context

        trigger: (eventName, args...) ->
            event = @genEventName eventName
            @module.getApplication().vent.trigger [event, @].concat(args)...

        delegateDomEvent: (view, eventName, exists) ->
            (args...) ->
                exists() if _.isFunction exists
                view.feature.trigger [eventName, view].concat(args)...

        delegateComponentEvent: (view, obj, eventName, exists) ->
            (args...) ->
                view.feature.trigger [eventName, view, obj.component].concat(args)...
                view.bindEventHandler(exists).apply view, args if _.isString exists

    Feature
