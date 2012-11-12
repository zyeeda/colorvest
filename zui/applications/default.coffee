define [
    'jquery'
    'underscore'
    'zui/coala/application'
    'zui/coala/browser'
    'zui/coala/component-handler'
    'zui/coala/config'
    'libs/jquery/pnotify/jquery.pnotify'
], ($, _, Application, detectBrowser, ComponentHandler, config) ->

    (options = {}) ->
        detectBrowser() if options.detectBrowser isnt false

        c = new Application()
        application = new Application()
        application.coala = c

        delete c.module
        c.paths = [config.coalaFeaturesPath]
        c.baseName = 'coala'
        c.applicationRoot = application
        c.getPromises = ->
            application.promises
        c.initRouters()

        application.addPromise ComponentHandler.initialize()

        if options.loadSettings isnt false
            application.addPromise $.get('invoke/scaffold/system/settings', (data) ->
                settings = {}
                _.each data.results, (d) ->
                    settings[d.name] = d.value
                application.settings = settings
                c.settings = settings
            )

        if options.useDefaultHome isnt false
            modifyFeatureContainerDeferred = $.Deferred()

            openedFeatures = {}
            application.done ->
                application.startFeature('coala/home').done (home) ->
                    application.mainTab = mainTab = home.layout.components[0]

                    mainTab.$el.bind 'tabsremove', (event, ui) ->
                        application.stopFeature openedFeatures[ui.tab.hash]

                    config.featureContainer = (feature) ->
                        id = '#' + feature.cid
                        openedFeatures[id] = feature
                        mainTab.addTab
                            url: id
                            label : feature.startupOptions.name or feature.baseName
                            closable: feature.options.closable isnt false
                            selected: true
                            fit: 'Home' isnt feature.startupOptions.name

                        feature.activate = _.bind (id) ->
                            mainTab.selectTab id
                        , feature, id

                        id

                    modifyFeatureContainerDeferred.resolve()

            application.addPromise modifyFeatureContainerDeferred

        if options.useDefaultNotifier isnt false
            # pnotify
            $.pnotify.defaults.history = false
            stack_bar_top = "dir1": "down", "dir2": "right", "push": "top", "spacing1": 0, "spacing2": 0
            application.message = (content, title = false) ->
                content = if _.isObject content then content else {text: content}
                content.title = title if _.isString title

                options = _.extend stack: stack_bar_top, addclass: 'stack-bar-top', width: '70%', cornerclass: "", content
                $.pnotify options

            application.error = (content, title = false) ->
                content = if _.isObject content then content else {text: content}
                content.title = title if _.isString title

                options = _.extend type: 'error', content
                application.message options

            application.info = (content, title = false) ->
                content = if _.isObject content then content else {text: content}
                content.title = title if _.isString title

                options = _.extend type: 'info', content
                application.message options

            application.success = (content, title = false) ->
                content = if _.isObject content then content else {text: content}
                content.title = title if _.isString title

                options = _.extend type: 'success', content
                application.message options

        # dialog
        application.showDialog = (options) ->
            deferred = $.Deferred()
            if not application._modalDialog
                application.startFeature('coala/dialog', options).done (feature) ->
                    application._modalDialog = feature
                    deferred.resolve feature
            else
                application._modalDialog.show(options).done (feature) ->
                    deferred.resolve feature
            deferred

        application
