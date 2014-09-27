define [
    'marionette'
    'cdeio/core/base-view'
    'cdeio/core/config'
], (Marionette, BaseView, config) ->
    {getPath} = config

    class Layout extends BaseView
        constructor: (@options) ->
            options.avoidLoadingHandlers = if options.avoidLoadingHandlers is false then false else true
            @feature = options.feature
            @vent = new Marionette.EventAggregator()
            @regions = options.regions or {}
            super options
            @regionManagers = {}

        render: ->
            @initializeRegions()
            super

        serializeData: ->
            data = super()
            data['__layout__'] = true
            data

        initializeRegions: Marionette.Layout.prototype.initializeRegions
        closeRegions: Marionette.Layout.prototype.closeRegions
        close: Marionette.Layout.prototype.close

    Marionette.Region.prototype.show = (view, appendMethod) ->
        @ensureEl()
        @close()
        view.setElement(@$el)
        @open(view, 'size')
        @currentView = view

    Layout
