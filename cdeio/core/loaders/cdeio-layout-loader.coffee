define [
    'underscore'
    'cdeio/core/layout'
    'cdeio/core/util'
    'cdeio/core/resource-loader'
    'cdeio/core/config'
], (_, Layout, util, loadResource, config) ->
    {error} = util

    type: 'layout'
    name: 'cdeio'
    fn: (module, feature, layoutName, args) ->
        deferred = $.Deferred()

        # 
        loadResource('cdeio/layouts/' + layoutName).done (def) ->
            error @, "No layout defined with name cdeio/layouts/#{layoutName}." if not def
            #error @, 'no layout defined with name: cdeio/layouts/', layoutName if not def
            options = _.extend {}, def,
                el: feature.container
                baseName: layoutName
                feature: feature
                module: module
                extend:
                    # 构造 layout 模板路径，覆盖 baseView 的方法。将路径固定。
                    getTemplateSelector: ->
                        'cdeio/layouts/templates/' + @baseName + config.templateSuffix

                    renderHtml: (su, data) ->
                        t = @feature.template
                        delete @feature.template
                        d = su.call @, data
                        @feature.template = t
                        d

                    initHandlers: (su, handler) ->
                        @eventHandlers ?= {}
                        # @eventHandlers || @eventHandlers = {}

                        if @options.avoidLoadingHandlers is true
                            deferred = $.Deferred()
                            deferred.resolve {}
                            return deferred.promise()
                        # 初始化时 加载 handler （avoidLoadingHandler==false 时）
                        loadResource('cdeio/layouts/handlers/' + (handler or @baseName)).done (handlers = {}) =>
                            _.extend @eventHandlers, handlers

            deferred.resolve new Layout options

        deferred.promise()
