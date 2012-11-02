
define [
    'jquery'
    'underscore'
    'marionette'
    'handlebars'
    'backbone'
    'zui/coala/application'
    'zui/coala/component-handler'
    'zui/coala/resource-loader'
    'zui/coala/config'
    'zui/applications/default'
    'zui/coala/loader-plugin-manager'
    'zui/plugins/default-feature-loader'
    'zui/plugins/default-view-loader'
    'zui/plugins/forms-view-loader'
    'zui/plugins/notfound-feature-loader'
    'zui/plugins/views-view-loader'
    'zui/plugins/tree-views-view-loader'
    'zui/plugins/treetable-views-view-loader'
    'zui/coala/sync'
], ($, _, Marionette, Handlebars, Backbone, Application, ComponentHandler, loadResource, config, startDefaultApplication, LoaderPluginManager, featureLoader, viewLoader, formsLoader, notFoundFeatureLoader, viewsLoader, treeViewsLoader, treeTableViewsLoader) ->

    # override marionette's template loader
    Marionette.TemplateCache.loadTemplate = (templateId, callback) ->
        loadResource(templateId, 'text').done (template) ->
            tpl = Handlebars.compile template or ''
            callback.call @, tpl

    Handlebars.registerHelper 'appearFalse', (value) -> if value is false then 'false' else value

    coala = {}

    LoaderPluginManager.register featureLoader
    LoaderPluginManager.register viewLoader
    LoaderPluginManager.register formsLoader
    LoaderPluginManager.register notFoundFeatureLoader
    LoaderPluginManager.register viewsLoader
    LoaderPluginManager.register treeViewsLoader
    LoaderPluginManager.register treeTableViewsLoader

    coala.startBackboneHistory = (app) ->
        Backbone.history = new Backbone.History() if not Backbone.history
        processedUrl = {}
        Backbone.history.handlers.push route:/^(.*)$/, callback: (name) ->
            return if processedUrl[name] is true or not name

            processedUrl[name] = true
            names = name.split '/'
            modules = {}
            _.reduce names, (memo, n) ->
                modules[memo] = app.findModule memo
                [memo, n].join '/'

            app.module name

            app.done =>
                i = names.length
                while i--
                    u = names[0..i].join '/'
                    m = app.findModule u
                    if not m.router and not modules[u]
                        delete m.parent[names[i]]

                Backbone.history.loadUrl name
        Backbone.history.start()

    coala.registerComponentHandler = (name, init, fn) ->
        ComponentHandler.register name, init, fn

    coala.startApplication = (path) ->
        if not path
            startDefaultApplication()
        else
            require(path)()

    coala.LoaderPluginManager = LoaderPluginManager

    coala
