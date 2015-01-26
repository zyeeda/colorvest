define [
    'underscore'
    'jquery'
    'cdeio/cdeio'
    'handlebars'
], (_, $, cdeio, Handlebars) ->

    cdeio.registerComponentHandler 'launcher', (->), (el, options, view) ->
        data = options.data or []
        map = {}
        map[item.id] = item for item in data

        folders = (item for item in data when not item.parent)
        for folder in folders
            folder.rows = (item for item in data when item.parent?.id is folder.id)
            for row in folder.rows
                row.items = (item for item in data when item.parent?.id is row.id)
            if _.every(folder.rows, (e) -> e.items.length is 0)
                fake = [id: 'fake-' + folder.id, name: folder.name, items: folder.rows]
                folder.rows = fake

        o = prepareDomElements folders: folders

        o.show = _.bind show, @, o
        o.hide = _.bind hide, @, o
        o.showTop = _.bind showTop, @, o
        component =
            show: o.show
            hide: o.hide

        o.container.click ->
            o.hide()

        $('.c-launcher-box', o.bottom).click (e) ->
            e.stopPropagation()
            p = $(@).parent()
            o.showTop p

        $('.c-launcher-top-row-item', o.top).click ->
            return if block.length isnt 0

            id = $(@).attr 'id'
            object = map[id]
            view.feature.trigger 'launcher:launch', view, component, object

        el.click ->
            o.show()

        component

    block = []
    transition = (start, end) ->
        if not $.support.transition
            start()
            end()
        else
            el = start()
            block.push el
            el.one $.support.transition.end, ->
                end()
                block.pop()

    active = (el) ->
        el.addClass 'active'

    deactive = (el) ->
        el.removeClass 'active'

    show = (o) ->
        return if o.started is true

        o.started = true
        $('.active', o.container).removeClass 'active'
        block.pop() while block.length isnt 0
        $('> *', o.topHelper).appendTo o.top
        delete o.activeFolder
        delete o.activeContent

        active o.container
        transition ->
            o.container[0].offsetWidth
            active(o.bottom)
        , ->
            active o.top

    hide = (o) ->
        return if block.length isnt 0

        transition ->
            o.top.css 'opacity', 0
        , ->
            deactive o.top
            o.top.css 'opacity', ''
            o.top.css 'height', 0

        transition ->
            o.bottom.css 'opacity', 0
        , ->
            deactive o.bottom
            deactive o.container
            o.bottom.css 'opacity', ''
            o.started = false

        if o.activeFolder
            deactive o.activeFolder
            deactive $('.c-launcher-arrow', o.activeFolder)
            delete o.activeFolder
        if o.activeContent
            deactive o.activeContent
            delete o.activeContent

    showTop = (o, p) ->
        return if p.hasClass('active') or block.length isnt 0

        if o.activeFolder
            deactive o.activeFolder
            deactive $('.c-launcher-arrow', o.activeFolder)
            active o.arrowHelper
            transition ->
                o.arrowHelper.css 'left', $('.c-launcher-arrow', p).position().left
            , ->
                active $('.c-launcher-arrow', p)
                deactive o.arrowHelper
        else
            o.arrowHelper.css 'left', $('.c-launcher-arrow', p).position().left
            active $('.c-launcher-arrow', p)

        o.activeFolder = active p

        id = 'c-' + p.attr('id')
        content = $('#' + id, o.top)
        active content

        height = o.contentHeights[id]
        transition ->
            o.top.height(height)
        , ->

        if o.activeContent
            o.activeContent.appendTo o.topHelper
            content.appendTo o.topHelper

            h = o.contentHeights[o.activeContent.attr('id')]
            transition ->
                o.topHelper.css 'top', -h
            , ->
                [first, second] = o.topHelper.children()
                deactive $(first)
                $(first).appendTo o.top
                $(second).appendTo o.top
                o.topHelper.css 'top', 0

        o.activeContent = content

    template = Handlebars.compile '''
        <div class="c-launcher-container" id="{{id}}">
          <div class="c-launcher-top">
            <!--<div class="c-launcher-top-shadow"></div>-->
            <div class="c-launcher-top-helper"/>
            {{#each folders}}
            <div class="c-launcher-top-content" id="c-{{id}}">
                {{#each rows}}
                <div class="c-launcher-top-row">
                    <div class="c-launcher-top-row-title">{{name}}</div>
                    <div class="c-launcher-top-row-items">
                    {{#each items}}
                        <div class="c-launcher-top-row-item" id="{{id}}">
                            <i class="c-launcher-top-row-item-icon {{iconClass}}">{{icon}}</i>
                            <div class="c-launcher-top-row-item-label">{{name}}</div>
                        </div>
                    {{/each}}
                    </div>
                    <div class="c-launcher-clear"></div>
                </div>
                {{/each}}
            </div>
            {{/each}}
          </div>
          <div class="c-launcher-bottom">
            <div class="c-launcher-arrow-helper"/>
            {{#each folders}}
            <div class="c-launcher-folder" id="{{id}}">
              <div class="c-launcher-arrow"/>
              <div class="c-launcher-box">
                <i class="c-launcher-icon {{iconClass}}">{{icon}}</i>
                <div class="c-launcher-label">{{name}}</div>
              </div>
            </div>
            {{/each}}
          </div>
        </div>
    '''

    prepareDomElements = (options) ->
        id = _.uniqueId 'launcher'
        options.id = id
        t = template options

        $(t).appendTo($(document.body))
        $('<div id="' + id + '-helper" class="c-launcher-helper"/>').appendTo($(document.body))

        container = $('#' + id)
        top = $('.c-launcher-top', container)
        bottom = $('.c-launcher-bottom', container)
        helper = $('#' + id + '-helper')
        result =
            container: container
            top: top
            bottom: bottom
            helper: helper
            topHelper: $('.c-launcher-top-helper', top)
            arrowHelper: $('.c-launcher-arrow-helper', bottom)
            contentHeights: {}
        $('.c-launcher-top-content', result.top).appendTo result.helper
        $('.c-launcher-top-content', result.helper).each ->
            me = $ @
            active me
            result.contentHeights[me.attr('id')] = me.height() + 40
            deactive me

        $('.c-launcher-top-content', result.helper).appendTo result.top

        result
