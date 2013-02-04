define [
    'underscore'
    'coala/coala'
    'coala/vendors/jquery/jquery.carouFredSel'
], (_, coala) ->

    class FeatureBar

        constructor: (footerEl) ->
            console.log footerEl
            pinWrapper = footerEl.children '.coala-taskbar-pin'
            carouselWrapper = footerEl.children '.coala-taskbar-carousel'
            @carouselContainer = carouselWrapper.children 'ul'

            @carouselContainer.carouFredSel
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

        add: (featureDef) ->
            itemTemplate = """
            <li>
                <div class="coala-taskbar-carousel-icon">
                    <img src="#{featureDef.icon}" alt="#{featureDef.name}" />
                    <div><i class="icon-remove-sign"></i></div>
                </div>
                <div class="coala-taskbar-carousel-text">#{featureDef.name}</div>
            </li>
            """
            @carouselContainer.trigger 'insertItem', [itemTemplate]

        scrollTo: (item) ->

        remove: (item) ->

    class FeatureWindow

        add: (item) ->

        switchTo: (item) ->

        remove: (item) ->

    class FeatureRegistry

        constructor: ->
            @registry = {}
            @list = []

        add: (feature) ->
            path = feature.path()
            @registry[path] = feature
            @list.push path

        remove: (featurePath) ->
            feature = @registry[featurePath]
            if feature?
                idx = _.lastIndexOf @list, featurePath
                @list.splice idx, 1
                delete @registry[featurePath]
            feature

        promote: (featurePath) ->
            feature = @registry[featurePath]
            if feature?
                idx = _.lastIndexOf @list, featurePath
                item = @list.splice idx, 1
                @list.push item
            feature

        contains: (featurePath) ->
            _.has @registry, featurePath

        pick: ->
            featurePath = _.last @list
            @registry[featurePath]

    coala.registerComponentHandler 'viewport', (->), (el, options, view) ->

        defaultOptions = {}

        options = _.extend defaultOptions, options

        mainEl = el.children '.coala-viewport-main'
        footerEl = el.children '.coala-viewport-footer'

        featureWindow = new FeatureWindow mainEl
        featureBar = new FeatureBar footerEl
        featureRegistry = new FeatureRegistry()

        viewport =
            showFeature: (opts) ->
                if featureRegistry.contains opts.path
                    feature = featureRegistry.promote opts.path
                    this._showFeature feature if feature?
                else
                    featureContainer = $ '<div></div>'
                    console.log opts.path
                    app.startFeature(opts.path, container: featureContainer).done (feature) ->
                    #app.startFeature(opts.path).done (feature) ->
                        console.log feature
                        featureRegistry.add feature
                        featureBar.add opts
                        featureWindow.add feature
                        this._showFeature feature

            _showFeature: (feature) ->
                featureBar.scrollTo feature
                featureWindow.switchTo feature

            closeFeature: (featurePath) ->
                if featureRegistry.contains featurePath
                    feature = featureRegistry.remove featurePath
                    if feature?
                        app.stopFeature feature
                        featureBar.remove feature
                        featureWindow.remove feature

                    nextFeature = featureRegistry.pick()
                    this._showFeature nextFeature

