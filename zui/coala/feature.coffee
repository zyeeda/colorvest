define [
    'jquery'
    'underscore'
    'zui/coala/config'
    'zui/coala/util'
    'zui/coala/model'
    'zui/coala/collection'
    'zui/coala/layout'
    'zui/coala/loader-plugin-manager'
], ($, _, config, util, Model, Collection, Layout, loaderPluginManager) ->
    {getPath} = config
    {log, error} = util

    class Feature
        constructor: (@options, @startupOptions = {}) ->
            @cid = _.uniqueId 'feature'
            @baseName = options.baseName
            @module = options.module
            @model = options.model if options.model
            @collection = options.collection if options.collection

            if @options.extend
                for key, value of @options.extend
                    old = @[key]
                    if _.isFunction value
                        value = _.bind value, @, old
                    @[key] = value

            @initRenderTarget()
            @deferredLayout = @initLayout()
            @deferredModel = @initModel()
            @deferredCollection = @initCollection()
            @deferredView = @initViews()

        initRenderTarget: ->
            target = @options.target or config.featureContainer
            target = target @ if _.isFunction target
            # in this case, target must be a selector or dom element or $element
            @container = target

        initLayout: ->
            layout = @options.layout
            layout = @baseName if not layout

            @module.loadResource(getPath @, 'layout', layout).done (def) =>
                error @, 'no layout defined with name:', getPath @, 'layout', layout if not def
                def.el = @container
                def.baseName = if layout.charAt(0) is '/' then layout.substring(1) else layout
                def.feature = @
                def.module = @module
                @layout = new Layout def

        initModel: ->
            return if @model
            deferred = $.Deferred()
            @module.loadResource(getPath @, 'model', @baseName).done (def) =>
                if not def
                    @modelDefinition = Model.extend feature: @
                    @model = new @modelDefinition()
                    deferred.resolve()
                else
                    def.feature = @
                    @modelDefinition = Model.extend def
                    @model = new @modelDefinition()
                    deferred.resolve()
            deferred.promise()

        initCollection: ->
            return if @collection
            @deferredModel.done =>
                @collection = new (Collection.extend feature: @)(null, model: @modelDefinition)

        initViews: () ->
            @inRegionViews = {}
            @views = {}

            views = []
            promises = [@deferredLayout,@deferredModel]
            for view in @options.views or []
                view = if _.isString(view) then name: view else view
                views.push view
                promises.push loaderPluginManager.invoke('view', @module, @, view.name, view)

            defered = $.when.apply($, promises).then _.bind (vs, u1,u2, args...) =>
                for v, i in args
                    @views[i] = @views[vs[i].name] = v
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
            @module.url(@baseName)

        # delegate $.ajax, do nothing but add url prefix
        request:  (options) ->
            options.url = @url() + '/' + options.url
            $.ajax options

        active: ->
            #override this

        stop: ->

        start:  ->
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
    Feature
