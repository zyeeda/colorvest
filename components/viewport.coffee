define [
    'underscore'
    'coala/coala'
    'coala/vendors/jquery/jquery.carouFredSel'
], (_, coala) ->

    class FeatureBar

        constructor: (footerEl) ->
            pinWrapper = footerEl.children '.coala-taskbar-pin'
            carouselWrapper = footerEl.children '.coala-taskbar-carousel'
            carouselContainer = carouselWrapper.children 'ul'

            carouselContainer.carouFredSel
                circular: false
                infinite: false
                auto: false
                align: 'left'
                prev:
                    button: carouselWrapper.children('.coala-taskbar-prev')
                next:
                    button: carouselWrapper.children('.coala-taskbar-next')
                height: footerEl.height()
                onCreate: ->
                    $(window).on 'resize', ->
                        carouselContainer.trigger 'updateSizes'

            @carouselContainer = carouselContainer

        add: (feature) ->
            item = $ """
            <li data-feature-id="#{feature.cid}">
                <div class="coala-taskbar-app-icon #{feature.startupOptions.icon}"></div>
                <div class="coala-taskbar-app-text">#{feature.startupOptions.name}</div>
                <div class="coala-taskbar-app-remove coala-icon-close"></div>
            </li>
            """
            @carouselContainer.trigger 'insertItem', [item]

        scrollTo: (featureId) ->
            item = @carouselContainer.children "[data-feature-id=#{featureId}]"
            @carouselContainer.trigger 'slideTo', item

        remove: (featureId) ->
            me = @
            item = me.carouselContainer.children "[data-feature-id=#{featureId}]"
            if $.support.transition
                item.one $.support.transition.end, ->
                    me.carouselContainer.trigger 'removeItem', item
                item.css 'opacity', 0
                item.css 'width', 0
            else
                me.carouselContainer.trigger 'removeItem', item

    class FeatureWindow

        constructor: (mainEl) ->
            @viewportCarousel = mainEl.children '.coala-viewport-carousel'

        ###
        add: (feature) ->
            @viewportCarousel.append feature.container.addClass 'coala-viewport-feature'
        ###
        add: (featureContainer) ->
            @viewportCarousel.append featureContainer

        switchTo: (featureId) ->
            current = @viewportCarousel.children ':visible'
            next = @viewportCarousel.children "[data-feature-id=#{featureId}]"
            current.hide()
            next.show()

        remove: (featureId) ->
            item = @viewportCarousel.children "[data-feature-id=#{featureId}]"
            item.remove()

    class FeatureRegistry

        constructor: ->
            @registry = {}
            @list = []

        add: (feature) ->
            featureId = feature.cid
            @registry[featureId] = feature
            @list.push featureId

        remove: (featureId) ->
            feature = @registry[featureId]
            if feature?
                idx = _.lastIndexOf @list, featureId
                @list.splice idx, 1
                delete @registry[featureId]
            feature

        promote: (featureId) ->
            feature = @registry[featureId]
            if feature?
                idx = _.lastIndexOf @list, featureId
                item = @list.splice idx, 1
                @list.push item[0]
            feature

        contains: (featureId) ->
            _.has @registry, featureId

        pick: ->
            featureId = _.last @list
            @registry[featureId]

        get: (featureId) ->
            @registry[featureId]

    coala.registerComponentHandler 'viewport', (->), (el, options, view) ->

        defaultOptions = {}

        options = _.extend defaultOptions, options

        mainEl = el.children '.coala-viewport-main'
        footerEl = el.children '.coala-viewport-footer'

        featureWindow = new FeatureWindow mainEl
        featureBar = new FeatureBar footerEl
        featureRegistry = new FeatureRegistry()

        viewport =
            showFeature: (feature) ->
                me = this
                featureId = feature.cid
                if featureRegistry.contains featureId
                    _feature = featureRegistry.promote featureId
                    me._showFeature _feature.cid
                else
                    featureRegistry.add feature
                    featureBar.add feature
                    #featureWindow.add feature
                    me._showFeature featureId

            _showFeature: (featureId) ->
                featureBar.scrollTo featureId
                featureWindow.switchTo featureId

            closeFeature: (feature) ->
                featureId = feature.cid
                if featureRegistry.contains featureId
                    featureRegistry.remove featureId
                    featureBar.remove featureId
                    nextFeature = featureRegistry.pick()
                    this._showFeature nextFeature.cid if nextFeature?
                    featureWindow.remove featureId

            createFeatureContainer: (feature) ->
                container = $ "<div data-feature-id='#{feature.cid}' class='coala-viewport-feature'></div>"
                featureWindow.add container
                container

        footerEl.delegate 'li', 'click', (event) ->
            $this = $ @
            $target = $ event.target
            if $this.hasClass 'coala-taskbar-show-launcher'
                view.feature.trigger 'viewport:show-launcher', view
                return

            if $target.hasClass 'coala-taskbar-app-remove'
                featureId = $this.attr 'data-feature-id'
                feature = featureRegistry.get featureId
                view.feature.trigger 'viewport:close-feature', view, feature
                return

            featureId = $this.attr 'data-feature-id'
            if featureId?
                viewport._showFeature featureId

        viewport

