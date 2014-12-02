define ['jquery'], ($) ->
    birt_toolbar_click: (e) ->
        if window.frames[0] && window.frames[0].BirtToolbar
            window.frames[0].BirtToolbar.prototype.__neh_click e
        else
            app.error '报表服务运行错误，请联系管理员!'

    birt_parameter_click: (e) ->
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
	    else
	    	if window.frames[0] && window.frames[0].BirtToolbar
		        window.frames[0].BirtToolbar.prototype.__neh_click e
		    else
		        app.error '报表服务运行错误，请联系管理员!'
