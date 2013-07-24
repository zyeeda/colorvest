define [
    'jquery'
    'underscore'
    'marionette'
    'handlebars'
    'backbone'
    'coala/core/component-handler'
    'coala/core/resource-loader'
    'coala/core/config'
    'coala/core/loader-plugin-manager'
    'coala/core/loaders/default-feature-loader'
    'coala/core/loaders/default-view-loader'
    'coala/core/loaders/default-layout-loader'
    'coala/core/loaders/inline-view-loader'
    'coala/core/loaders/coala-layout-loader'
    'coala/core/loaders/coala-feature-loader'
    'coala/core/handlebar-helpers'
    'coala/core/sync'
    'bootstrap'
    'coala/features/dialog.feature/feature'
    'coala/features/routers'
], ($, _, Marionette, Handlebars, Backbone, ComponentHandler, loadResource, config, LoaderPluginManager, featureLoader, viewLoader, layoutLoader, inlineViewloader, coalaLayoutLoader, coalaFeatureLoader) ->

    # override marionette's template loader
    Marionette.TemplateCache.loadTemplate = (templateId, callback) ->
        loadResource(templateId, 'text').done (template) ->
            if template
                callback.call @, Handlebars.compile template
            else
                callback.call @, null

    coala = {}

    LoaderPluginManager.register featureLoader
    LoaderPluginManager.register viewLoader
    LoaderPluginManager.register layoutLoader
    LoaderPluginManager.register inlineViewloader
    LoaderPluginManager.register coalaLayoutLoader
    LoaderPluginManager.register coalaFeatureLoader

    attachDefaultApplicationMethods = (app) ->

        # This is a shortcut for default view loader.
        app.loadView = (feature, name, args...) ->
            throw new Error('a view must be within a feature') if not feature
            args = ['view', feature.module, feature, name].concat args
            LoaderPluginManager.invoke args...

        # dialog
        app.showDialog = (options) ->
            deferred = $.Deferred()
            if not app._modalDialog
                app.startFeature('coala:dialog', options).done (feature) ->
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

    coala.startBackboneHistory = (app) ->
        Backbone.history = new Backbone.History() if not Backbone.history
        app.initRouters().done ->
            Backbone.history.start()

    coala.registerComponentHandler = (name, init, fn) ->
        ComponentHandler.register name, init, fn

    if config.loadSettings isnt false and config.noBackend isnt true
        path = 'system/settings/all'
        prefix = config.urlPrefix
        path = if _.isFunction prefix
            prefix undefined, path
        else
            prefix + path

        settingsPromise = $.get(path, (data) ->
            config.settings = _.extend {}, data
        )

    coala.startApplication = (path, options = {}) ->
        if _.isObject path
            options = path
            path = null

        options = _.extend {}, options,
            settingsPromise: settingsPromise

        app = if not path
            require('coala/applications/default')(options)
        else
            require(path)(options)

        attachDefaultApplicationMethods app

        if options?.initFeatures
            features = if _.isString(options.initFeatures) then [options.initFeatures] else options.initFeatures
            featureOptions = if _.isArray(options.initFeatureOptions) then options.initFeatureOptions else [options.initFeatureOptions]
            app.done ->
                app.startFeature name, featureOptions[i] for name, i in features

        app.done ->
            console.log 'd'
            console.log app.getPromises().length
            coala.startBackboneHistory app

        app

    coala.LoaderPluginManager = LoaderPluginManager

    coala
