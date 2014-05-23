define [
    'jquery'
    'underscore'
    'handlebars'
    'marionette'
    'coala/core/config'
    'coala/core/view'
    'coala/core/form-view'
    'coala/core/form/form-group'
    'coala/core/form/form-field'
], ($, _, H, M, config, View, FormView, FormGroup, FormField) ->

    class CustomFormView extends FormView

        constructor: (options) ->
            opt = _.extend {}, options
            super opt
            @promises.push @initTpl options

        initTpl: (options) ->
            deferred = $.Deferred()
            M.TemplateCache.get(@module.resolveResoucePath(@feature.baseName + '.feature/views/' + @baseName + config.templateSuffix)).done (tpl) =>
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
            template = _.template(@getTemplateString()) o

        getTemplateString: -> '''
            <form class="<%= formClass %>">
                <%= content %>
                <input type="hidden" name="__formName__" value="<%= formName %>"/>
            </form>
        '''
    
    View.add 'custom-form-view', CustomFormView

    CustomFormView
