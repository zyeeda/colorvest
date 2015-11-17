define [
    'underscore'
    'jquery'
    'bootstrap'
    'cdeio/features/dialog.feature/views/dialog-title'
    'cdeio/features/dialog.feature/views/dialog-buttons'
    'text!cdeio/features/dialog.feature/templates.html'
], (_, $) ->
    layout:
        regions:
            title: "modal-header"
            body: "modal-body"
            buttons: "modal-footer"

    views: [
        name: 'dialog-title'
        region: 'title'
    ,
        name: 'dialog-buttons'
        region: 'buttons'
    ]

    avoidLoadingModel: true

    extend:
        initRenderTarget: (su) ->
            root = @module.getApplication()
            @dialogId = _.uniqueId('dialog')
            viewSize = @startupOptions.view.options.size or 'medium'

            $('<div class="modal hide c-modal-size-' + viewSize + '" id="' + @dialogId + '"><div id="' + @startupOptions.view.cid + '"></div>').appendTo document.body
            @containerId = @dialogId
            @dialogContainer = c = $('#' + @dialogId)
            c.on 'hide', (event) =>
                event.preventDefault()  if @startedOptions.length > 1
                @close()

            c.addClass @startupOptions.view.options.dialogClass if @startupOptions.view.options.dialogClass
            @container = $('#' + @startupOptions.view.cid)

        stop: (su) ->
            root = @module.getApplication()
            @dialogContainer.removeClass @startupOptions.view.options.dialogClass  if @startupOptions.view.options.dialogClass
            su.apply this

        start: (su) ->
            me = this
            deferred = $.Deferred()
            startedOptions = me.startedOptions or (me.startedOptions = [])
            startedOptions.push me.startupOptions
            me.inRegionViews['body'] = me.startupOptions.view
            me.startupOptions.view.dialogFeature = @
            @deferredView.done ->
                promise = su.call(me)
                promise.done ->
                    me.modal = $('#' + me.containerId).modal(backdrop: 'static')
                    deferred.resolve me

            deferred.promise()

        show: (su, options) ->
            # 最新的 dialog 所属 view
            view = $('#' + options.view.cid)
            # dialog 原有的所属 view
            currentView = @startupOptions.view

            viewSize = options.view.options.size or 'medium'
            currentViewSize = currentView.options.size or 'medium'

            deferred = $.Deferred()
            unless view.size() is 0
                currentView.dialogFeature = @
                @dialogContainer.removeClass currentView.options.dialogClass  if currentView.options.dialogClass
                @dialogContainer.addClass options.view.options.dialogClass  if options.view.options.dialogClass
                @startedOptions.push options
                $('#' + currentView.cid).hide()

                if viewSize != currentViewSize
                    $('#' + @dialogId).removeClass('c-modal-size-' + currentViewSize)
                    $('#' + @dialogId).addClass('c-modal-size-' + viewSize)

                view.show()
                deferred.resolve this
                deferred
            else
                @dialogContainer.append '<div id=\"' + options.view.cid + '\"></div>'
                @container = $('#' + options.view.cid)
                @initLayout().done =>
                    @dialogContainer.removeClass currentView.options.dialogClass  if currentView.options.dialogClass
                    @dialogContainer.addClass options.view.options.dialogClass  if options.view.options.dialogClass
                    $('#' + currentView.cid).hide()

                    if viewSize != currentViewSize
                        $('#' + @dialogId).removeClass('c-modal-size-' + currentViewSize)
                        $('#' + @dialogId).addClass('c-modal-size-' + viewSize)

                    @startupOptions = options
                    @start().done =>
                        deferred.resolve @
                deferred.promise()

        hide: ->
            @modal.modal 'hide'

        close: -> # for close button
            # 取出最上层的 view
            options = @startedOptions.pop()

            if _.isFunction(options.beforeClose)
                if (options.beforeClose.call options, options) is false
                    @startedOptions = @startedOptions
                    @startedOptions.pop = ->
                        return options
                    return false

            if _.isFunction(options.onClose)
                options.onClose.apply options

            delete options.view.dialogFeature

            if @startedOptions.length > 0
                current = @startedOptions[@startedOptions.length - 1]
                @dialogContainer.removeClass options.view.options.dialogClass  if options.view.options.dialogClass
                @dialogContainer.addClass current.view.options.dialogClass  if current.view.options.dialogClass
                @startupOptions = current
                $('#' + options.view.cid).hide()
                $('#' + current.view.cid).show()

                viewSize = options.view.options.size or 'medium'
                currentViewSize = current.view.options.size or 'medium'

                if viewSize != currentViewSize
                    $('#' + @dialogId).removeClass('c-modal-size-' + viewSize)
                    $('#' + @dialogId).addClass('c-modal-size-' + currentViewSize)

            else
                app = @module.getApplication()
                app.stopFeature this
                app._modalDialog = null
                @dialogContainer.remove()
