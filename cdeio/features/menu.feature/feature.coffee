define ['underscore', 'cdeio/vendors/jquery/jquery.slimscroll.min'], (_) ->
    layout:
        regions:
            top: 'sidebar-shortcuts'
            center: 'center'
            bottom: 'sidebar-collapse'

    views: [
        name: 'inline:shortcut', region: 'top', avoidLoadingHandlers: true
    ,
        name: 'menu', region: 'center'
    ,
        name: 'inline:tool', region: 'bottom', events:
            'click btn': 'minMenu'
    ]

    extend:
        activateMenu: (_super, url) ->
            menuView = @views.menu
            models = menuView.collection.where(path: url)
            if models.length > 0
                menuItem = menuView.$('child-' + models[0].get('id')).parent()
                @_lightUpMenu menuItem
                models[0]

        _lightUpMenu: (_super, menuItem) ->
            menuItem.parents('ul.nav').find('.active').removeClass 'active'
            subMenuContainer = menuItem.parents('ul.submenu')
            if subMenuContainer.length > 0
                @_openSubMenu subMenuContainer  unless subMenuContainer.is(':visible')
                subMenuContainer.parent().addClass 'active'
            menuItem.addClass 'active'

        _openSubMenu: (_super, menuItem, options) ->
            options = _.extend({}, options)
            return false  if @_isMiniMenu(menuItem)
            if options.enableAnimation
                menuItem.slideToggle(200).parent().addClass 'open'
            else
                menuItem.show().parent().addClass 'open'

        _closeSubMenu: (_super, menuItem, options) ->
            options = _.extend({}, options)
            return false  if @_isMiniMenu(menuItem)
            if options.enableAnimation
                menuItem.slideToggle(200).parent().removeClass 'open'
            else
                menuItem.hide().parent().removeClass 'open'

        _isMiniMenu: (_super, menuItem) ->
            menuItem.prev().hasClass 'menu-min'

        onStart: () ->
            logoHeight = 46
            shortcutsHeight = 40
            collapseHeight = 28
            @views['menu'].$el.slimScroll
                height: $(document).height() - (logoHeight + shortcutsHeight + collapseHeight) + 'px'
                color: '#393939'
                wheelStep: 5