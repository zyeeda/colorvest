define [
    'jquery'
    'underscore'
    'handlebars'
    'marionette'
    'cdeio/core/config'
    'cdeio/core/view'
    'cdeio/core/form-view'
    'cdeio/core/form/form-group'
    'cdeio/core/form/form-field'
], ($, _, H, M, config, View, FormView, FormGroup, FormField) ->

    class CustomFormView extends FormView

        constructor: (options) ->
            opt = _.extend {}, options
            super opt
            @promises.push @initTpl options

        initTpl: (options) ->
            deferred = $.Deferred()
            path = if @options.template then @module.resolveResoucePath('/' + @options.template) else @module.resolveResoucePath(@feature.baseName + '.feature/views/' + @baseName + config.templateSuffix)
            M.TemplateCache.get(path).done (tpl) =>
                @tpl = tpl
                deferred.resolve()
                return deferred.promise() 
            deferred.promise()

        initForm: (form, fieldGroups, options) ->
            groups = form.groups
            groups = if _.isArray groups then groups else [groups]
            @groups = (@createGroup group, fieldGroups for group in groups)
            events = {}
            components = []
            @eachField (field) ->
                _.extend events, es if (es = field.getEvents())
                components = components.concat cs if (cs = field.getComponents())

            options.events = _.extend options.events or {}, events
            options.components = (options.components or []).concat components

        getTemplate: ->
            style = 'form-horizontal' if @options.labelOnTop is false
            style += ' c-action-form c-action-form-' + @options.formName if @options.formName?

            o = formClass: style, formName: @options.formName
            content = {}
            @eachField (field) ->
                content[field.name] = field.getTemplate()
                content[field.name + 'Id'] = field.id
            o.content = @tpl(content)
            o.hiddens = (group.getHiddenFieldsTemplate() for group in @groups).join ''
            template = _.template(@getTemplateString()) o
    
    View.add 'custom-form-view', CustomFormView

    CustomFormView
