define

    avoidLoadingHandlers: true

    extend:
        serializeData: (su) ->
        	data = su.apply @
        	data.report = @feature.startupOptions.report
        	_params = ''
        	if @feature.startupOptions.params
        		for p of @feature.startupOptions.params
        			_params += "&#{p}=#{@feature.startupOptions.params[p]}"
        	data.params = _params
        	data