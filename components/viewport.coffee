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
                <div class="coala-taskbar-remove-sign coala-icon-close"></div>
            </li>
            """
            @carouselContainer.trigger 'insertItem', [item]

        scrollTo: (featureId) ->
            item = @carouselContainer.children "[data-feature-id=#{featureId}]"
            @carouselContainer.trigger 'slideTo', item

        remove: (featureId) ->
            me = @
            item = me.carouselContainer.children "[data-feature-id=#{featureId}]"
            item.css 'opacity', 0
            item.css 'width', 0
            if $.support.transition
                item.one $.support.transition.end, ->
                    me.carouselContainer.trigger 'removeItem', item
            else
                me.carouselContainer.trigger 'removeItem', item

    class FeatureWindow

        constructor: (mainEl) ->
            @viewportCarousel = mainEl.children '.coala-viewport-carousel'
            @viewportCarousel.carouFredSel
                circular: false
                infinite: false
                auto: false
                items:
                    visible: 1
                scroll:
                    fx: 'crossfade'

        add: (feature) ->
            @viewportCarousel.trigger 'insertItem', [feature.container]

        switchTo: (featureId) ->
            item = @viewportCarousel.children "[data-feature-id=#{featureId}]"
            @viewportCarousel.trigger 'slideTo', item

        remove: (featureId) ->
            item = @viewportCarousel.children "[data-feature-id=#{featureId}]"
            @viewportCarousel.trigger 'removeItem', item

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
                    featureWindow.add feature
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

        footerEl.delegate 'li', 'click', ->
            if $(@).hasClass 'coala-taskbar-app'
                view.feature.trigger 'viewport:show-launcher', view
                return

            featureId = $(@).attr 'data-feature-id'
            if featureId?
                viewport._showFeature featureId

        footerEl.delegate '.coala-taskbar-remove-sign', 'click', ->
            li = $(@).parent 'li'
            featureId = li.attr 'data-feature-id'
            feature = featureRegistry.get featureId
            view.feature.trigger 'viewport:close-feature', view, feature

        viewport

