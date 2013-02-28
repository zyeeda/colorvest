define [
    'jquery'
    'underscore'
    'marionette'
    'handlebars'
    'backbone'
    'coala/core/application'
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
    'coala/features/dialog/feature'
], ($, _, Marionette, Handlebars, Backbone, Application, ComponentHandler, loadResource, config, LoaderPluginManager, featureLoader, viewLoader, layoutLoader, inlineViewloader, coalaLayoutLoader, coalaFeatureLoader) ->

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

        # load view
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
            deferred

        if not app.confirm then app.confirm = (content, fn) ->
            fn() if window.confirm content

        if not app.prompt then app.prompt = (content, fn) ->
            s = window.prompt(content)
            fn(s) if s

        fn = (content, title = '') -> alert title + ': ' + content
        app[name] = fn for name in ['success', 'info', 'error', 'message'] when not app[name]

        app

    coala.startBackboneHistory = (app) ->
        Backbone.history = new Backbone.History() if not Backbone.history
        app.initRouters().done ->
            Backbone.history.start()

    coala.registerComponentHandler = (name, init, fn) ->
        ComponentHandler.register name, init, fn

    coala.startApplication = (path) ->
        app = if not path
            require('coala/applications/default')()
        else
            require(path)()

        attachDefaultApplicationMethods app

    coala.LoaderPluginManager = LoaderPluginManager

    coala
