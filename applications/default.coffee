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
    'coala/features/home'
], ($, _, coala, Application, detectBrowser, ComponentHandler, config) ->

    onContextLogin = false

    $(document).on 'ajaxComplete', (e, response, options) ->
        if response.status is 401 and not onContextLogin
            onContextLogin = true

            login = $ '#LOGIN-DIALOG'
            if login.length is 0
                $('''
                    <div class="modal hide fade" id="LOGIN-DIALOG">
                      <div class="modal-header">
                        <h3>Login</h3>
                      </div>
                      <div class="modal-body">
                        <iframe src="" class="context-login-iframe"></iframe>
                      </div>
                    </div>
                ''').appendTo(document.body)
                login = $ '#LOGIN-DIALOG'
                login.on 'hidden', ->
                    onContextLogin = false

            $('iframe', login).attr('src', config.ssoProviderUrl)
            login.modal
                backdrop: 'static'
                keyboard: false

    (options = {}) ->
        detectBrowser() if options.detectBrowser isnt false

        application = new Application()
        application.addPromise ComponentHandler.initialize()

        if options.loadSettings isnt false and config.noBackend isnt true
            application.addPromise $.get(config.urlPrefix + '/system/settings', (data) ->
                settings = {}
                _.each data.results, (d) ->
                    settings[d.name] = d.value
                application.settings = settings
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

            application.confirm = (content, fn) ->
                fn() if window.confirm content

            application.prompt = (content, fn) ->
                s = window.prompt(content)
                fn(s) if s


        application
