define [
    'jquery'
    'underscore'
    'coala/coala'
    'coala/core/application'
    'coala/core/browser'
    'coala/core/component-handler'
    'coala/core/config'
    'coala/core/form-view'
    'coala/vendors/jquery/pnotify/jquery.pnotify'
    'coala/scaffold/scaffold'
    'coala/features/home.feature/feature'
    'coala/components/viewport'
    'coala/components/launcher'
], ($, _, coala, Application, detectBrowser, ComponentHandler, config) ->

    onContextLogin = false

    $(document).on 'ajaxComplete', (e, response, options) ->
        if response.status is 401 and not onContextLogin
            onContextLogin = true

            login = $ '#LOGIN-DIALOG'
            if login.length is 0
                login = $('''
                    <div class="modal hide fade" id="LOGIN-DIALOG">
                      <div class="modal-header">
                        <h3>Login</h3>
                      </div>
                      <div class="modal-body">
                        <iframe src="" class="context-login-iframe"></iframe>
                      </div>
                    </div>
                ''').appendTo document.body
                #login = $ '#LOGIN-DIALOG'
                login.on 'hidden', ->
                    onContextLogin = false

            $('iframe', login).attr 'src', config.ssoProviderUrl

            login.modal
                backdrop: 'static'
                keyboard: false

    (options = {}) ->
        detectBrowser() if options.detectBrowser isnt false

        application = new Application()
        application.addPromise ComponentHandler.initialize()

        if options.loadSettings isnt false and config.noBackend isnt true
            path = 'system/settings/all/settings'
            prefix = config.urlPrefix
            path = if _.isFunction prefix
                prefix application, path
            else
                prefix + path

            application.addPromise $.get(path, (data) ->
                application.settings = _.extend {}, data
            )

        if options.useDefaultHome isnt false
            modifyFeatureContainerDeferred = $.Deferred()

            application.done ->
                application.startFeature('coala:home').done (homeFeature) ->
                    config.featureContainer = (feature) ->
                        viewport = homeFeature.views['inline:viewport'].components[1]

                        feature.activate = ->
                            viewport.showFeature feature

                        start0 = _.bind feature.start, feature
                        feature.start = ->
                            start0().done ->
                                viewport.showFeature feature

                        stop0 = _.bind feature.stop, feature
                        feature.stop = ->
                            stop0()
                            viewport.closeFeature feature

                        viewport.createFeatureContainer feature

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

            application.confirm = (content, fn) ->
                fn() if window.confirm content

            application.prompt = (content, fn) ->
                s = window.prompt(content)
                fn(s) if s

        application
