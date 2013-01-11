define [
    'jquery'
    'underscore'
    'coala/coala'
    'jqueryui/tabs'
], ($, _, coala) ->

    proto =
        addTab: (options) ->
            addFn = @$el.tabs 'option', 'add'
            tabTemplate = @$el.tabs 'option', 'tabTemplate'

            @$el.tabs 'option', 'add', (event, ui) =>
                addFn event, ui

                if options.selected is true
                    @$el.tabs 'select', '#' + ui.panel.id

                if options.fit is true
                    $panel = $ ui.panel
                    $panel.innerHeight $panel.parent().height()
                    $panel.addClass 'ui-tabs-panel-fit'

            if options.closable is true
                @$el.tabs 'option', 'tabTemplate', '<li><a href="#{href}">#{label}</a><i class="ui-icon ui-icon-close"></i></li>'

            @$el.tabs 'add', options.url, options.label, options.index

            @$el.tabs 'option', 'add', addFn if options.selected is true
            @$el.tabs 'option', 'tabTemplate', tabTemplate if options.closable is true

            return

        removeTab: (index) ->
            index ?= @$el.tabs 'option', 'selected'
            @$el.tabs 'remove', index
            return

        selectTab: (index, options) ->
            if @tabExists index
                @$el.tabs 'select', index
                return true

            if options?
                if _.isString options
                    options =
                        url: index
                        label: options
                        selected: true
                options.url = index unless options.url?
                @addTab options

            return false

        tabExists: (index) ->
            $(index).length isnt 0

        disableTab: (index) ->
            index ?= @$el.tabs 'option', 'selected'
            @$el.tabs 'disable', index
            return

        enableTab: (index) ->
            index ?= @$el.tabs 'option', 'selected'
            @$el.tabs 'enable', index
            return

        disable: ->
            @$el.tabs 'disable'
            return

        enable: ->
            @$el.tabs 'enable'
            return

        length: ->
            return @$el.tabs 'length'

        dispose: ->
            $('ul.ui-widget-header', @$el).off 'click'
            @$el.removeData 'zui.tabs'
            @$el.tabs 'destroy'
            return

    coala.registerComponentHandler 'tabs', (->), (el, opt, view) ->
        ###
        # options
        #   hashBase
        #   router
        ###
        options = _.extend {}, opt

        addFn = options.add
        options.add = (event, ui) ->
            $panel = $(ui.panel)
            $panel.appendTo $panel.prev()

            return addFn event, ui if addFn?

        showFn = options.show
        options.show = (event, ui) ->
            $.layout.callbacks.resizeTabLayout event, ui if $.layout?
            showFn event, ui if showFn?

        if options.router?
            selectFn = options.select
            options.select = (event, ui) ->
                hashBase = options.hashBase ? ''
                href = $(ui.tab).attr 'href'
                href = href.substring 1 if href.indexOf '#' is 0
                href = "#{hashBase}#{href}"
                if href isnt window.location.hash
                    options.router.setLocation href
                    return false

                selectFn event, ui if selectFn?

        $el = $ el
        unless $el.data('zui.tabs')?
            $el.tabs options

            $('.ui-tabs-nav', $el).on 'click', '.ui-icon-close', ->
                index = $('li', $el).index $(this).parent()
                $el.tabs 'remove', index

            $el.data 'zui.tabs', $.extend $el: $el, proto

        $el.data 'zui.tabs'
