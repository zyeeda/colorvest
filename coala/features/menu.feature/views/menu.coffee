define [
    'jquery'
    'underscore'
    'handlebars'
], ($, _, H) ->
    parseData = (data) ->
        items = {}
        result = []
        _.each data, (item) ->
            items[item.id] = item
            item.children = []
            result.push item    unless item.parent

        _.each data, (item) ->
            items[item.parent.id].children.push item    if item.parent

        result

    templates =
        leaf: H.compile '''
            <li><a href="{{path}}" id="child-{{id}}" data-id="{{id}}">{{#if iconClass}}<i class="{{iconClass}}"></i>{{/if}}
                <span class="menu-text">{{name}}</span>
            </a> </li>
        '''
        branch: H.compile '''
            <li> <a href="javascript:void 0;" class="dropdown-toggle" id="parent-{{id}}">
                {{#unless isRoot}}<i class="icon-double-angle-right"></i>{{/unless}}
                {{#if iconClass}}<i class="{{iconClass}}"></i>{{/if}}
                <span class="menu-text">{{name}}</span><b class="arrow icon-angle-down"></b> </a>
                <ul class="submenu" {{#opened}}style="display:block;"{{/opened}}>{{{childrenHtml}}}</ul>
            </li>
        '''

    processNode = (node, isRoot) ->
        isLeaf = node.children.length is 0
        htmls = []
        unless isLeaf
            _.each node.children, (item) ->
                htmls.push processNode(item)

            node.childrenHtml = htmls.join('')
        node.isRoot = isRoot
        templates[(if isLeaf then 'leaf' else 'branch')] node

    events:
        'click parent-*': 'toggleSubMenu'

    model: 'system/menu/all'
    extend:
        serializeData: (su) ->
            deferred = $.Deferred()
            c = @collection
            data = su.apply(this)
            me = this
            c.fetch().done ->
                data.items = parseData(c.toJSON())
                deferred.resolve data

            deferred.promise()

        renderHtml: (su, data) ->
            htmls = []
            _.each data.items, (item) ->
                htmls.push processNode(item, true)

            '<ul class="nav nav-list" id="menu">' + htmls.join('') + '</ul>'
