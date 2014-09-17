define [
    'jquery'
    'underscore'
    'marionette'
    'handlebars'
    'backbone'
    'cdeio/core/component-handler'
    'cdeio/core/resource-loader'
    'cdeio/core/config'
    'cdeio/core/loader-plugin-manager'
    'cdeio/core/loaders/default-feature-loader'
    'cdeio/core/loaders/default-view-loader'
    'cdeio/core/loaders/default-layout-loader'
    'cdeio/core/loaders/inline-view-loader'
    'cdeio/core/loaders/cdeio-layout-loader'
    'cdeio/core/loaders/cdeio-feature-loader'
    'cdeio/core/handlebar-helpers'
    'cdeio/core/sync'
    'bootstrap'
    'cdeio/features/dialog.feature/feature'
    'cdeio/features/routers'
], ($, _, Marionette, Handlebars, Backbone, ComponentHandler, loadResource, config, LoaderPluginManager, featureLoader, viewLoader, layoutLoader, inlineViewloader, cdeioLayoutLoader, cdeioFeatureLoader) ->

    # override marionette's template loader
    Marionette.TemplateCache.loadTemplate = (templateId, callback) ->
        loadResource(templateId, 'text').done (template) ->
            if template
                callback.call @, Handlebars.compile template
            else
                callback.call @, null

    cdeio = {}

    LoaderPluginManager.register featureLoader
    LoaderPluginManager.register viewLoader
    LoaderPluginManager.register layoutLoader
    LoaderPluginManager.register inlineViewloader
    LoaderPluginManager.register cdeioLayoutLoader
    LoaderPluginManager.register cdeioFeatureLoader

    attachDefaultApplicationMethods = (app) ->
        # dialog
        app.showDialog = (options) ->
            deferred = $.Deferred()
            if not app._modalDialog
                app.startFeature('cdeio:dialog', options).done (feature) ->
                    app._modalDialog = feature
                    deferred.resolve feature
            else
                app._modalDialog.show(options).done (feature) ->
                    deferred.resolve feature
            deferred.promise()

        if not app.confirm then app.confirm = (content, fn) ->
            fn() if confirm content

        if not app.prompt then app.prompt = (content, fn) ->
            s = prompt content
            fn s if s

        fn = (content, title = '') -> alert title + ': ' + content
        app[name] = fn for name in ['success', 'info', 'error', 'message'] when not app[name]

        app

    cdeio.startBackboneHistory = (app) ->
        Backbone.history = new Backbone.History() if not Backbone.history
        app.initRouters().done ->
            Backbone.history.start()

    cdeio.registerComponentHandler = (name, init, fn) ->
        ComponentHandler.register name, init, fn

    if config.loadSettings isnt false and config.noBackend isnt true
        path = 'system/settings/all?' + new Date().getTime()
        prefix = config.urlPrefix
        path = if _.isFunction prefix
            prefix undefined, path
        else
            prefix + path

        settingsPromise = $.get(path, (data) ->
            config.settings = _.extend {}, data
        )

    cdeio.startApplication = (path, options = {}) ->
        if _.isObject path
            options = path
            path = null

        options = _.extend {}, options,
            settingsPromise: settingsPromise

        app = if not path
            require('cdeio/applications/default')(options)
        else
            require(path)(options)

        attachDefaultApplicationMethods app

        if options?.initFeatures
            features = if _.isString(options.initFeatures) then [options.initFeatures] else options.initFeatures
            featureOptions = if _.isArray(options.initFeatureOptions) then options.initFeatureOptions else [options.initFeatureOptions]
            app.done ->
                app.startFeature name, featureOptions[i] for name, i in features

        app.done ->
            cdeio.startBackboneHistory app
            $(window).on 'resize', -> app.vent.trigger 'window#resize'

        app

    cdeio.LoaderPluginManager = LoaderPluginManager

    cdeio
