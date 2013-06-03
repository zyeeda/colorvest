define [
    'jquery'
    'underscore'
    'coala/coala'
    'coala/core/application'
    'coala/core/browser'
    'coala/core/component-handler'
], ($, _, coala, Application, detectBrowser, ComponentHandler) ->

    (options = {}) ->
        detectBrowser() if options.detectBrowser isnt false

        application = new Application()
        application.addPromise ComponentHandler.initialize()
        application.addPromise options.settingsPromise if options.settingsPromise

        application
