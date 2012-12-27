define ["jquery", "underscore"], ($, _) ->
    handler = (app, featureName, id, data) ->
        data.option = eval '(' + data.option + ')' if data.option and _.isString(data.option)
        app.startFeature featureName, data
        @$$("li.active").removeClass "active"
        @$(id).parent().addClass "active"

    model: "system/menuitems"
    avoidLoadingHandlers: true
    extend:
        serializeData: ->
            deferred = $.Deferred()
            me = this
            app = me.feature.module.getApplication().applicationRoot
            $.when(@collection.fetch()).done ->
                me.collection.each (data, i) ->
                    id = data.get("id")
                    featureName = data.get("featurePath")
                    e = undefined
                    me.eventHandlers[id] = _.bind(handler, me, app, featureName, id, data.toJSON())
                    e = me.wrapEvent("click " + id, id)
                    me.events[e.name] = e.handler

                me.delegateEvents()
                deferred.resolve data: me.collection.toJSON()

            deferred
