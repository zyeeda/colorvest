define [
    'marionette'
    'coala/core/base-view'
    'coala/core/config'
], (Marionette, BaseView, config) ->
    {getPath} = config

    class Layout extends BaseView
        constructor: (@options)->
            @feature = options.feature
            @vent = new Marionette.EventAggregator()
            @regions = options.regions or {}
            super options
            @regionManagers = {}

        render: ->
            @initializeRegions()
            super

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