define ["underscore"], (_) ->
    avoidLoadingHandlers: true
    extend:
        templateHelpers: ->
            buttons = @feature.startupOptions.buttons
            @eventHandlers or (@eventHandlers = {})
            i = 0
            while i < buttons.length
                id = _.uniqueId("button")
                buttons[i].id = id
                e = @wrapEvent("click " + id, id)
                @events[e.name] = e.handler
                @eventHandlers[id] = ((fn) ->
                    result = fn.apply(this)
                    @feature.modal.modal "hide"  if result isnt false
                ).bind(this, buttons[i].fn)
                i++
            el = @$el
            @$el = @feature.dialogContainer
            @delegateEvents()
            @$el = el
            buttons: @feature.startupOptions.buttons
