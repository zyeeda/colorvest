define [
    'backbone'
], (Backbone) ->
    class Model extends Backbone.Model
        url: ->
            path = @path
            # url = @view?.url() or @feature?.url() or ''
            if @feature.baseName is 'inline-grid'
            	url = @view?.url() or @feature?.url() or ''
            	if @feature.startupOptions.gridOptions.form.options.feature.activeTab and @feature.startupOptions.url
	            	url = @feature.startupOptions.url + '/history/' + @feature.startupOptions.gridOptions.form.model.get 'id'
            else
            	url = @view?.url() or @feature?.url() or ''

            url = if path then url + '/' + path else url
            # 如果为 流程 feature，则在请求地址 scaffold 后加上 process
            if @feature.activeTab
                if _.isUndefined(@taskOperatorType)
                    url = url + '/process/' + @feature.activeTab
                else
                    url = url + '/task/' + @taskOperatorType

            if _.isUndefined @taskOperatorType
                if @isNew() then url else url + '/' + encodeURIComponent(@id)
            else
                if @isNew() then url else url + '/' + encodeURIComponent(@id) + '|' + @._t_taskId
    Model
