define [
    'marionette'
    'jquery'
    'underscore'
    'zui/coala/config'
    'zui/coala/component-handler'
    'zui/coala/util'
], (Marionette, $, _, config, ComponentHandler, util) ->
    {getPath} = config
    {error} = util

    class BaseView extends Marionette.ItemView
        constructor: (@options) ->
            @promises or= []
            @module = options.module
            @feature = options.feature
            @baseName = options.baseName

            if options.extend
                for key, value of options.extend
                    old = @[key]
                    if _.isFunction value
                        value = _.bind value, @, old
                    @[key] = value

            super options
            @promises.push @initHandlers(options.handlersIn)

        initialize: (options) ->
            events = options.events or {}
            events = events.apply @ if _.isFunction events
            @events = {}

            for name, value of events
                if @feature.isFeatureEvent name
                    @feature.on name, @bindEventHandler value
                else
                    e = @wrapEvent name, value
                    @events[e.name] = e.handler

            delegates = options.delegates or {}
            delegates = delegates.apply @ if _.isFunction delegates
            for name, value of delegates
                e = @wrapEvent name, null
                @events[e.name] = @feature.delegateDomEvent(@, value, @events[e.name])

        wrapEvent: (name, handlerName) ->
            parts = name.replace(/^\s+/g, '').replace(/\s+$/, '').split /\s+/
            if parts.length is 2
                name = parts[0] + ' #' + @genId(parts[1])

            return name: name if not handlerName

            if not _.isFunction handlerName
                handler = @bindEventHandler handlerName
            else
                handler = _.bind handlerName, @

            name: name, handler: handler

        bindEventHandler: (name) ->
            (args...) =>
                method = @eventHandlers[name]
                error @, "no handler named #{name}" if not method
                method.apply @, args

        initHandlers: (handler) ->
            @eventHandlers ?= {}

            if @options.avoidLoadingHandlers is true
                deferred = $.Deferred()
                deferred.resolve {}
                return deferred.promise()

            path = getPath(@feature, 'handler', handler or @baseName)
            @module.loadResource(path).done (handlers = {}) =>
                _.extend @eventHandlers, handlers

        template: ->
            name = @options.template or @baseName
            getPath @feature, 'template', name

        getTemplateSelector: ->
            template = @template
            if _.isFunction template
                template = template.call this
            @module.resolveResoucePath template + config.templateSuffix

        mixinTemplateHelpers: (target) ->
            data = super(target)
            _.extend data, settings: @feature.module.getApplication().settings

        afterRender: ->
            @options.afterRender.call @ if _.isFunction @options.afterRender

        render: (fn) ->
            deferred = $.Deferred()
            $.when.apply($, @promises).then =>
                super.done =>
                    fn() if _.isFunction fn
                    deferred.resolve()
            deferred.promise()

        genId: (id) ->
            return "#{@cid}-#{id}"

        $: (selector) ->
            super '#' + @genId(selector)

        $$: (selector) ->
            @$el.find selector

        onRender: ->
            used = {}
            @$el.find('[id]').each (i, el) =>
                $el = $ el
                id = $el.attr('id')
                error @, "ID: #{id} is used twice." if used[id] is true
                used[id] = true
                $el.attr 'id', @genId(id)

            #rewrite data-target for bootstrap
            @$el.find('[data-target]').each (i, el) =>
                $el = $ el
                dt = $el.attr 'data-target'
                dt = dt.substring 1 if dt.charAt(0) is '#'
                $el.attr 'data-target', '#'+ @genId(dt)

            @$el.find('[data-parent]').each (i, el) =>
                $el = $ el
                dt = $el.attr 'data-parent'
                dt = dt.substring 1 if dt.charAt(0) is '#'
                $el.attr 'data-parent', '#' + @genId(dt)

            #id for label
            @$el.find('label[for]').each (i, el) =>
                $el = $ el
                f = $el.attr 'for'
                $el.attr 'for', @genId(f)

            components = []
            evalComponent = (view, $el, options) ->
                {type, selector} = options

                delete options.type
                delete options.selector

                el = if selector then view.$ selector else $el
                components.push ComponentHandler.handle(type, el, options, @)
            evalAction = (view, $el, options) ->
                {action, selector} = options

                delete options.action
                delete options.selector

                el = if selector then view.$ selector else $el
                el[action]?.call el, options
            for component in @options.components or []
                component = component.call @ if _.isFunction component
                continue if not component
                (if component.type then evalComponent else evalAction).call @, @, @$el, _.extend({}, component)

            componentDeferred = $.Deferred()
            $.when.apply($, components).done (args...) =>
                @components = args
                componentDeferred.resolve(args)

            afterRenderDeferred = @afterRender.call @
            $.when(componentDeferred, afterRenderDeferred).promise()
    BaseView
