define [
    'jquery'
    'underscore'
    'cdeio/core/base-view'
    'cdeio/core/config'
    'cdeio/core/model'
    'cdeio/core/collection'
], ($, _, BaseView, config, Model, Collection) ->
    {getPath} = config

    class View extends BaseView
        constructor: (@options) ->
            @baseName = options.baseName
            @feature = options.feature
            @module = options.module
            @model = options.model
            super options

            @deferredModel = @initModel()
            @deferredCollection = @initCollection()
            @promises?.push @deferredModel
            @promises?.push @deferredCollection

        url: ->
            @feature.url() + '/' + @baseName

        initModel: ->
            deferred = $.Deferred()
            if @model
                if _.isFunction @model
                    @model = @model.call @
                if _.isString @model
                    u = @feature.module.getApplication().url @model
                    @modelDefinition = Model.extend url: -> u
                    @model = new @modelDefinition()
                deferred.resolve()
                return deferred.promise()

            if not @options.path
                @model = @feature.model
                # TODO 将此类参数移植到 feature.collection 外的其他地方，以便多标签时容易扩展
                @feature.collection.extra = {} if not @feature.collection.extra
                @feature.collection.extra['_task_type'] = @options.extra['_task_type'] if @options.extra and @options.extra['_task_type']
                @collection = @feature.collection
                deferred.resolve()
                return deferred.promise()

            if @options.avoidLoadingModel is true
                @modelDefinition = Model.extend feature: @feature, path: @options.path
                @model = new @modelDefinition()
                deferred.resolve()
                return deferred.promise()

            @module.loadResource(getPath @feature, 'model', @options.path).done (def) =>
                if not def
                    @modelDefinition = Model.extend feature: @feature, path: @options.path
                    @model = new @modelDefinition()
                    deferred.resolve()
                else
                    def.feature = @feature
                    def.path = @options.path
                    @modelDefinition = Model.extend def
                    @model = new @modelDefinition()
                    deferred.resolve()
            deferred.promise()

        initCollection: ->
            if @collection
                # @collection.extra = @options.extra or {}
                @collection.extra = {} if not @collection.extra
                @collection.extra['_task_type'] = @options.extra['_task_type'] if @options.extra and @options.extra['_task_type']
                return
            @deferredModel.done =>
                @collection = new (Collection.extend {feature: @feature, path: @options.path, extra: @options.extra or {}})(null, model: @modelDefinition)

    viewTypes = {}
    View.add = (type, clazz) ->
        viewTypes[type] = clazz
    View.build = (options) ->
        type = options.type
        return new View options if not type or not viewTypes[type]
        new viewTypes[type] options

    View
