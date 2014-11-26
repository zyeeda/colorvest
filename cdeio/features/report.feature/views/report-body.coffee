define

    avoidLoadingHandlers: true

    extend:
        serializeData: (su) ->
            data = su.apply @
            data.report = @feature.startupOptions.report
            data.load = true
            _params = ''
            if @feature.startupOptions.params
                for p of @feature.startupOptions.params
                    _params += "&#{p}=#{@feature.startupOptions.params[p]}"
                data.params = _params

            else if @feature.startupOptions.paramsView
                if @feature.startupOptions.paramsView
                    view = @feature.startupOptions.paramsView
                    app.showDialog
                        view: view
                        title: '参数设置'
                        buttons: [
                            label: '确定',
                            status: 'btn-primary',
                            fn: =>
                                return false unless view.isValid()
                                app.startFeature('cdeio:report', {report: @feature.startupOptions.report, params: view.getFormData(), paramsView: view, callback: @feature.startupOptions.callback}).done (feature) ->
                                    callback = feature.startupOptions.callback
                                    callback.call feature, feature if $.isFunction callback

                        ]
                data.load = false
            data
