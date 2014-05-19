define [
    'jquery'
    'underscore'
    'coala/coala'
    'coala/core/application'
    'coala/core/browser'
    'coala/core/component-handler'
    'coala/core/config'
    'coala/core/form-view'
    'coala/core/custom-form-view'
    'coala/vendors/jquery/jquery.gritter'
    'coala/vendors/bootbox'
    'coala/scaffold/scaffold'
    'coala/features/viewport.feature/feature'
    'coala/components/viewport'
    'coala/components/launcher'
    'coala/components/file-picker'
], ($, _, coala, Application, detectBrowser, ComponentHandler, config) ->

    onContextLogin = false

    $(document).on 'ajaxComplete', (e, response, options) ->
        if response.status is 422 and app
            data = JSON.parse response.responseText

            message = ''
            if data.violations
                message += "<li>#{v.message}</li>" for v in data.violations when v.message
            message = "<ul>#{message}</ul>" if message isnt ''

            app.error '请求验证失败' + message
        if response.status is 500 and app
            app.error '系统错误'
        else if response.status is 401 and not onContextLogin
            onContextLogin = true

            login = $ '#LOGIN-DIALOG'
            if login.length is 0
                login = $('''
                    <div class="modal hide fade" id="LOGIN-DIALOG">
                      <div class="modal-header">
                        <h3>上下文登录</h3>
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
        if options.settingsPromise
            application.addPromise options.settingsPromise.done ->
                application.settings = config.settings

        if options.useDefaultHome isnt false
            modifyFeatureContainerDeferred = $.Deferred()

            application.done ->
                application.startFeature('coala:viewport').done (homeFeature) ->
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

            for action in ['message', 'info', 'success', 'warn', 'error']
                do (action) ->
                    application[action] = (message) ->
                        message = text: message if _.isString message
                        message.title = '系统消息'
                        message.class_name = (if action is 'message' then '' else 'gritter-' + action)
                        $.gritter.add message

            application.alert = (message) ->
                bootbox.alert message

            application.confirm = (message, fn) ->
                bootbox.confirm message, '取消', '确定', fn

            application.prompt = (message, fn) ->
                bootbox.prompt message, '取消', '确定', fn

        application
