define [
    'cdeio/core/view'
    'handlebars'
    'underscore'
    'jquery'
    'cdeio/core/process-form-view'
    'cdeio/core/form/form-field'
    'cdeio/core/util'
    'cdeio/scaffold/form-view-loader' # 引入的目的是要注册里面的 picker
], (View, Handlebars, _, $, ProcessFormView, FormField, util, FormViewLoader) ->
    {log} = util

    type: 'view'
    name: 'process-form'
    fn: (module, feature, viewName, args) ->
        deferred = $.Deferred()
        log baseName: 'process-form-view-loader:MultiGridPickerField', 
            'viewName': viewName
        url = if feature.activeTab then 'configuration/process/forms/' + viewName else 'configuration/forms/' + viewName
        feature.request url: url, success: (data = {groups: []}) ->
            def = _.extend
                baseName: viewName
                module: module
                feature: feature
                avoidLoadingHandlers: true
                entityLabel: data.entityLabel
                formName: viewName
            , data
            def.form =
                groups: data.groups
                tabs: data.tabs
            view = new ProcessFormView def
            view.eventHandlers.formStatusChanged = (e) ->
                scaffold = @feature.options.scaffold or {}
                fsc = scaffold.handlers?.formStatusChanged
                if _.isFunction fsc
                    fsc.call @, @getFormData(), $(e.target)

            deferred.resolve view

        deferred.promise()
