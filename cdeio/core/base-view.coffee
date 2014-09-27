define [
    'marionette'
    'jquery'
    'underscore'
    'cdeio/core/config'
    'cdeio/core/component-handler'
    'cdeio/core/util'
], (Marionette, $, _, config, ComponentHandler, util) ->
    {getPath} = config
    {error} = util

    class BaseView extends Marionette.ItemView
        constructor: (@options) ->
            options.avoidLoadingModel = if options.avoidLoadingModel is false then false else true
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
            @deferHandlers = @initHandlers(options.handlersIn)
            @promises.push @deferHandlers

        initialize: (options) ->
            events = options.events or {}
            events = events.apply @ if _.isFunction events
            @events = {}

            for name, value of events
                if @feature.isFeatureEvent name
                    @feature.on @, name, @bindEventHandler value
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
                if parts[1].charAt(parts[1].length - 1) is '*'
                    n = parts[1].substring 0, parts[1].length - 1
                    n = @genId n
                    n = ' [id^="' + n + '"]'
                    name = parts[0] + n
                else
                    name = parts[0] + ' #' + @genId(parts[1])

            return name: name if not handlerName

            if not _.isFunction handlerName
                handler = @bindEventHandler handlerName
            else
                handler = _.bind handlerName, @

            name: name, handler: handler

        bindEventHandler: (name, namespace) ->
            (args...) =>
                fn = =>
                    handlers = if namespace then @eventHandlers[namespace] else @eventHandlers
                    error @,  "no namespace named #{namespace}" if not handlers
                    method = handlers[name]
                    error @, "no handler named #{name}" if not method
                    method.apply @, args

                if @options.avoidLoadingHandlers
                    fn()
                else
                    @deferHandlers.done => fn()

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

        renderHtml: (data) ->
            if @feature.template
                @feature.template data
            else
                super data

        serializeData: ->
            data = super()
            data['__viewName__'] = @baseName
            data['__view__'] = @
            data

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

        findComponent: (selector) ->
            o = c for c in @components when c['__options__']?.selector is selector
            o

        renderComponents: (delay) ->
            @components or= []

            d = delay or ''
            return if _.indexOf(@renderredComponents, d) isnt -1
            @renderredComponents.push d

            components = []
            originalOptions = []
            for component, i in @options.components or []
                component = component.call @ if _.isFunction component
                continue if not component

                if (not delay and not component.delay) or (delay is component.delay)
                    originalOptions[i] = component
                    options = _.extend {}, component
                    {type, selector} = options
                    delete options.type
                    delete options.selector

                    el = if selector then @$ selector else @$el
                    components[i] = ComponentHandler.handle(type, el, options, @)
                else
                    originalOptions[i] = component
                    components[i] = @components[i] or false

            componentDeferred = $.Deferred()
            $.when.apply($, components).done (args...) =>
                @components = args
                for arg, i in args
                    continue if not arg
                    arg['__options__'] = originalOptions[i]
                componentDeferred.resolve(args)

            componentDeferred.promise()

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

            @renderredComponents = []
            delays = @defaultComponentDelay
            delays = if _.isArray delays then delays else [delays]
            promises = (@renderComponents(delay) for delay in delays)

            $.when.apply($, promises).then( =>
                @afterRender.call @
            ).promise()

        dispose: ->
            c.dispose?() for c in @components if @components
            @undelegateEvents()
            @unbindAll()

    BaseView
