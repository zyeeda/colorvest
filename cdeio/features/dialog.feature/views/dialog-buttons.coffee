define ["underscore"], (_) ->
    avoidLoadingHandlers: true
    extend:
        templateHelpers: ->
            @buttons = buttons = @feature.startupOptions.buttons
            @eventHandlers or (@eventHandlers = {})
            i = 0
            while i < buttons.length
                id = _.uniqueId("button")
                buttons[i].id = id
                e = @wrapEvent("click " + id, id)
                @events[e.name] = e.handler
                @eventHandlers[id] = _((fn, b) ->
                    return if @$(id).hasClass('disabled')
                    # 解决重复提交问题
                    if b.greyable isnt false
                        @$(id).addClass('disabled')
                        @$(id).addClass('btn-grey')

                    result = fn.apply(this, [b])
                    
                    @$(id).removeClass('disabled')
                    @$(id).removeClass('btn-grey')

                    @feature.modal.modal "hide"  if result isnt false
                ).bind(this, buttons[i].fn, buttons[i])
                i++
            el = @$el
            @$el = @feature.dialogContainer
            @delegateEvents()
            @$el = el
            buttons: @feature.startupOptions.buttons
