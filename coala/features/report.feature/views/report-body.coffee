define

    avoidLoadingHandlers: true

    extend:
        serializeData: (su) ->
        	data = su.apply @
        	data.report = @feature.startupOptions.report
        	data.sample = @feature.startupOptions.sample
        	data