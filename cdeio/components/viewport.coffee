define [
    'underscore'
    'cdeio/cdeio'
    'cdeio/vendors/jquery/jquery.carouFredSel'
], (_, cdeio) ->

    class TaskBar

        constructor: (options) ->
            @defaultStartupOptionMap = {}
            for opt in options.defaultFeatureStartupOptions
                @defaultStartupOptionMap[opt.featurePath] = opt if opt.featurePath

            @homepageFeaturePath = options.homepageFeaturePath

            @footerEl = options.el
            @footerEl.html '''
                <div class="c-taskbar c-taskbar-pin">
                    <ul>
                        <li id="launcherEntry" class="c-taskbar-show-launcher">
                            <i class="c-taskbar-app-icon icon-globe"></i>
                            <div class="c-taskbar-app-text">所有应用</div>
                        </li>
                        <li id="homepageEntry" class="c-taskbar-show-homepage c-taskbar-app-selected">
                            <i class="c-taskbar-app-icon icon-cloud"></i>
                            <div class="c-taskbar-app-text">首页</div>
                        </li>
                    </ul>
                </div>
                <div class="c-taskbar c-taskbar-carousel">
                    <ul></ul>
                    <a href="javascript:void 0;" class="c-taskbar-prev"><i class="icon-chevron-left"></i></a>
                    <a href="javascript:void 0;" class="c-taskbar-next"><i class="icon-chevron-right"></i></a>
                </div>
            '''
            @pinWrapper = @footerEl.children '.c-taskbar-pin'
            carouselWrapper = @footerEl.children '.c-taskbar-carousel'
            carouselContainer = carouselWrapper.children 'ul'

            carouselContainer.carouFredSel
                circular: false
                infinite: false
                auto: false
                align: 'left'
                prev:
                    button: carouselWrapper.children('.c-taskbar-prev')
                next:
                    button: carouselWrapper.children('.c-taskbar-next')
                onCreate: ->
                    $(window).on 'resize', ->
                        carouselContainer.trigger 'updateSizes'
            ,
                debug: true

            @carouselContainer = carouselContainer

        _clearSelected: ->
            @footerEl.find('.c-taskbar-app-selected').removeClass 'c-taskbar-app-selected'

        add: (feature) ->
            if feature.path() is @homepageFeaturePath
                homepageEntry = @pinWrapper.find '.c-taskbar-show-homepage'
                homepageEntry.attr 'data-feature-id', feature.cid
            else
                @_clearSelected()

                _.extend feature.startupOptions, @defaultStartupOptionMap[feature.path()]
                item = $ """
                <li data-feature-id="#{feature.cid}" class="c-taskbar-app-selected">
                    <i class="c-taskbar-app-icon #{feature.startupOptions.iconClass}"></i>
                    <div class="c-taskbar-app-text">#{feature.startupOptions.name}</div>
                    <button class="close c-taskbar-app-remove">×</button>
                </li>
                """
                @carouselContainer.trigger 'insertItem', [item]

        scrollTo: (featureId) ->
            @_clearSelected()

            item = @pinWrapper.find "[data-feature-id=#{featureId}]"
            item = @carouselContainer.children "[data-feature-id=#{featureId}]" if item.length is 0
            item.addClass 'c-taskbar-app-selected'
            @carouselContainer.trigger 'slideTo', item

        remove: (featureId) ->
            me = @
            item = me.carouselContainer.children "[data-feature-id=#{featureId}]"
            d = $.Deferred()

            if $.support.transition
                item.one $.support.transition.end, ->
                    me.carouselContainer.trigger 'removeItem', item
                    d.resolve()

                item.css 'opacity', 0
            else
                me.carouselContainer.trigger 'removeItem', item
                d.resolve()

            d.promise()

    class FeatureWindow

        constructor: (mainEl) ->
            @viewportCarousel = mainEl

        add: (featureContainer) ->
            @viewportCarousel.append featureContainer

        hideCurrent: ->
            current = @viewportCarousel.children ':visible'
            current.hide()

        showNext: (featureId) ->
            next = @viewportCarousel.children "[data-feature-id=#{featureId}]"
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

    cdeio.registerComponentHandler 'viewport', (->), (el, options, view) ->

        defaultOptions = {}
        options = _.extend defaultOptions, options

        mainEl = el.children '.c-viewport-content'
        footerEl = el.children '.c-viewport-footer'

        featureBar = new TaskBar
            el: footerEl
            defaultFeatureStartupOptions: options.defaultFeatureStartupOptions
            homepageFeaturePath: options.homepageFeaturePath
        featureWindow = new FeatureWindow mainEl
        featureRegistry = new FeatureRegistry()

        viewport =
            showFeature: (feature) ->
                me = this
                featureId = feature.cid
                if featureRegistry.contains featureId # already shown
                    _feature = featureRegistry.promote featureId
                    me._showFeature _feature.cid
                else # the first time show
                    featureRegistry.add feature
                    featureBar.add feature
                    featureWindow.showNext featureId

            _showFeature: (featureId) ->
                featureBar.scrollTo featureId
                featureWindow.hideCurrent()
                featureWindow.showNext featureId

            closeFeature: (feature) ->
                me = @
                featureId = feature.cid
                if featureRegistry.contains featureId
                    featureRegistry.remove featureId
                    featureBar.remove(featureId).done ->
                        nextFeature = featureRegistry.pick()
                        me._showFeature nextFeature.cid if nextFeature?
                        featureWindow.remove featureId

            createFeatureContainer: (feature) ->
                # hide current feature first to prevent scrollbar to display
                featureWindow.hideCurrent()
                container = $ "<div data-feature-id='#{feature.cid}' class='c-viewport-feature'></div>"
                featureWindow.add container
                container

        footerEl.delegate 'li', 'click', (event) ->
            $this = $ @
            $target = $ event.target

            if $target.hasClass 'c-taskbar-app-remove'
                featureId = $this.attr 'data-feature-id'
                feature = featureRegistry.get featureId
                view.feature.trigger 'viewport:close-feature', view, feature
                return

            featureId = $this.attr 'data-feature-id'
            if featureId?
                viewport._showFeature featureId
            else
                view.feature.trigger 'viewport:show-launcher', view

        viewport
