define [
    'jquery'
    'underscore'
    'cdeio/cdeio'
    'cdeio/core/application'
    'cdeio/core/browser'
    'cdeio/core/component-handler'
], ($, _, cdeio, Application, detectBrowser, ComponentHandler) ->

    (options = {}) ->
        detectBrowser() if options.detectBrowser isnt false

        application = new Application()
        application.addPromise ComponentHandler.initialize()
        application.addPromise options.settingsPromise if options.settingsPromise

        application
