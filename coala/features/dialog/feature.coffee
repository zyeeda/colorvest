define [
    'underscore'
    'jquery'
    'bootstrap'
    'coala/features/dialog/__views__/dialog-title'
    'coala/features/dialog/__views__/dialog-buttons'
    'text!coala/features/dialog/templates.html'
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
            id = _.uniqueId('dialog')
            me = this
            $('<div class=\"modal hide\" id=\"' + id + '\"><div id=\"' + @startupOptions.view.cid + '\"></div>').appendTo document.body
            @containerId = id
            @dialogContainer = c = $('#' + id)
            c.on 'hide', (event) ->
                event.preventDefault()  if me.startedOptions.length > 1
                me.close()

            c.addClass @startupOptions.view.options.dialogClass  if @startupOptions.view.options.dialogClass
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
                    me.modal = $('#' + me.containerId).modal()
                    deferred.resolve me


            deferred.promise()

        show: (su, options) ->
            view = $('#' + options.view.cid)
            currentView = @startupOptions.view
            deferred = $.Deferred()
            unless view.size() is 0
                currentView.dialogFeature = @
                @dialogContainer.removeClass currentView.options.dialogClass  if currentView.options.dialogClass
                @dialogContainer.addClass options.view.options.dialogClass  if options.view.options.dialogClass
                @startedOptions.push options
                $('#' + currentView.cid).hide()
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
                    @startupOptions = options
                    @start().done =>
                        deferred.resolve @
                deferred.promise()

        close: -> # for close button
            options = @startedOptions.pop()
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
            else
                app = @module.getApplication()
                app.stopFeature this
                app._modalDialog = null
                @dialogContainer.remove()
