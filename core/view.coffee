define [
    'jquery'
    'underscore'
    'coala/core/base-view'
    'coala/core/config'
    'coala/core/model'
    'coala/core/collection'
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
            return if @collection
            @deferredModel.done =>
                @collection = new (Collection.extend {feature: @feature, path: @options.path})(null, model: @modelDefinition)

    viewTypes = {}
    View.add = (type, clazz) ->
        viewTypes[type] = clazz
    View.build = (options) ->
        type = options.type
        return new View options if not type or not viewTypes[type]
        new viewTypes[type] options

    View
