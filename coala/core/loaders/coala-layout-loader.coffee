define [
    'underscore'
    'coala/core/layout'
    'coala/core/util'
    'coala/core/resource-loader'
    'coala/core/config'
], (_, Layout, util, loadResource, config) ->
    {error} = util

    type: 'layout'
    name: 'coala'
    fn: (module, feature, layoutName, args) ->
        deferred = $.Deferred()

        loadResource('coala/layouts/' + layoutName).done (def) ->
            error @, "No layout defined with name coala/layouts/#{layoutName}." if not def
            #error @, 'no layout defined with name: coala/layouts/', layoutName if not def
            options = _.extend {}, def,
                el: feature.container
                baseName: layoutName
                feature: feature
                module: module
                extend:
                    getTemplateSelector: ->
                        'coala/layouts/templates/' + @baseName + config.templateSuffix

                    renderHtml: (su, data) ->
                        t = @feature.template
                        delete @feature.template
                        d = su.call @, data
                        @feature.template = t
                        d

                    initHandlers: (su, handler) ->
                        @eventHandlers ?= {}

                        if @options.avoidLoadingHandlers is true
                            deferred = $.Deferred()
                            deferred.resolve {}
                            return deferred.promise()

                        loadResource('coala/layouts/handlers/' + (handler or @baseName)).done (handlers = {}) =>
                            _.extend @eventHandlers, handlers

            deferred.resolve new Layout options

        deferred.promise()
