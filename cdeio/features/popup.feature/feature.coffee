define [
    'jquery',
    'underscore',
    'scripts/cdeio/vendors/jquery/jquery.magnific-popup.js'
], ($, _)->
    layout:
        regions:
            title: 'popup-title',
            content: 'popup-content',
            buttons: 'popup-buttons'

    views: [
        name: 'inline:popup-title',
        region: 'title',
        avoidLoadingHandlers: true
        extend:
            templateHelpers: ->
                title = @feature.startupOptions.title
                title: title
    ,
        name: 'inline:popup-buttons',
        region: 'buttons',
        avoidLoadingHandlers: true
        extend:
            templateHelpers: ->
                buttons = @feature.startupOptions.buttons
                buttons: buttons
    ]

    avoidLoadingModel: true

    extend:
        initRenderTarget: (_super) ->
            viewSizeMapping =
                mini: 'span2 offset5'
                small: 'span4 offset4'
                medium: 'span6 offset3'
                large: 'span8 offset2'
                xlarge: 'span10 offset1'
                xxlarge: 'span12'

            popupId = _.uniqueId 'popup'
            containerId = @startupOptions.view.cid
            popupClass = viewSizeMapping[@startupOptions.view.options.size or 'medium']
            @startupOptions.view.options.popupClass = popupClass

            template = _.template '''
                <div id="<%= popupId %>" class="row-fluid mfp-hide">
                    <div<% if (popupClass) { %> class="<%= popupClass %>"<% } %>>
                        <div class="position-relative">
                            <div class="widget-box no-border">
                                <div class="widget-body">
                                    <div class="widget-main">
                                        <div class="widget-box no-border">
                                            <div class="widget-body">
                                                <div id="<%= containerId %>" class="widget-main">
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            ''',
                popupId: popupId,
                containerId: containerId,
                popupClass: popupClass

            $(template).appendTo document.body

            @popupId = popupId

            @popupContainer = $ '#' + popupId
            @widgetContainer = @popupContainer.children().eq 0
            @container = $ '#' + containerId

        start: (_super) ->
            deferred = $.Deferred()

            @startupOptions.view.popupFeature = @

            @activeStartupOptions or= []
            @activeStartupOptions.push @startupOptions
            @inRegionViews.content = @startupOptions.view

            @deferredView.done =>
                promise = _super.call @
                promise.done =>
                    $.magnificPopup.open
                        items:
                            src: @popupContainer
                            type: 'inline'
                        showCloseBtn: false
                        closeOnBgClick: false

            deferred.promise()

        activate: (_super, options) ->
            deferred = $.Deferred()
            currentView = @startupOptions.view
            view = $ '#' + options.view.cid
            if view.size() is 0
                prevContainer = @container
                @container = $ "<div id=\"#{options.view.cid}\" class=\"widget-main\"></div>"
                @container.appendTo prevContainer.parent()
                @initLayout().done =>
                    @widgetContainer.removeClass currentView.options.popupClass if currentView.options.popupClass
                    @widgetContainer.addClass options.view.options.popupClass if options.view.options.popupClass
                    prevContainer.hide()
                    @startupOptions = options
                    @start().done =>
                        deferred.relative @
            else
            deferred.promise()

        close: ->
            options = @activeStartupOptions.pop()
            if _.isFunction options.onClose
                options.onClose options

            delete options.view.popupFeature

            if @activeStartupOptions.length > 0
                current = @activeStartupOptions[@activeStartupOptions.length - 1]
                @widgetContainer.removeClass options.view.options.popupClass if options.view.options.popupClass
                @widgetContainer.addClass current.view.options.popupClass if current.view.options.popupClass
                @startupOptions = current
                $('#' + options.view.cid).hide()
                $('#' + current.view.cid).show()
            else
                root = @module.getApplication()
                root.stopFeature @
                @popupContainer.remove()
