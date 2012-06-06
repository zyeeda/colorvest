define [
    'cs!libs/zui/coala'
], (coala) ->

    coala.ComponentHandler.regist 'tab', 'jqueryui/tabs', ($el, options = {}) ->
        $el.tabs options

    coala.ComponentHandler.regist 'layout', 'libs/jquery/layout/jquery.layout', ($el, options = {}) ->
        $el.layout options

    window.app = app = new coala.Application()

    app.mainTabOperator =
        exists: {}
        openedFeatures: {}
        add: (feature) ->
            id = '#' + feature.cid
            if not (id of @exists)
                @exists[id] = app.mainTab.tabs 'length'
                tabTemplate = if feature.options.closable
                    '<li><a href="#{href}"><span>#{label}</span></a><span class="ui-icon ui-icon-close" onclick="app.mainTabOperator.remove(\'#{href}\');">Remove Tab</span></li>'
                else
                    '<li><a href="#{href}"><span>#{label}</span></a></li>'
                app.mainTab.tabs 'option', 'tabTemplate', tabTemplate
                app.mainTab.tabs 'add', id, feature.options.label or feature.baseName
                @openedFeatures[id] = feature
            @select id
        index: (id) ->
            @exists[id]
        remove: (id) ->
            app.mainTab.tabs 'remove', @index(id)
            delete @exists[id]
            app.stopFeature @openedFeatures[id]
            delete @openedFeatures[id]
        select: (id) ->
            app.mainTab.tabs 'select', @index(id)

    coala.ComponentHandler.initialize().done ->
        app.startFeature('main/home').done (home)->
            app.mainTab = home.layout.components[1]
            coala.featureContainer = (feature) ->
                app.mainTabOperator.add feature
                feature.active = _.bind (id) ->
                    app.mainTabOperator.select id
                , feature, '#' + feature.cid
                '#' + feature.cid
        .done ->
            app.startFeature('main/home-page')
    app
