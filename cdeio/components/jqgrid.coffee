define [
    'underscore'
    'cdeio/cdeio'
    'cdeio/components/callbacks/grid'
    'cdeio/vendors/jquery/jqgrid/i18n/grid.locale-cn'
    'cdeio/vendors/jquery/jqgrid/jquery.jqGrid.src'
], (_, cdeio, cbGrid) ->

    delegateGridEvents = (view, obj, options, prefix) ->
        events = [
            'onSelectRow', 'gridComplete', 'beforeRequest', 'onCellSelect'
            'loadBeforeSend', 'loadComplete', 'ondblClickRow', 'onHeaderClick', 'onPaging'
            'onRightClickRow', 'onSelectAll', 'onSortCol', 'serializeGridData'
        ]
        for event in events
            do (event) ->
                options[event] = view.feature.delegateComponentEvent view, obj, prefix + ':' + event, options[event]

    ###
    cdeio.registerComponentHandler 'grid', (->), (el, options, view) ->

        defaultOptions =
            autowidth: options.fit
            forceFit: options.fit
            cellLayout: 17 # padding: 0 8px; border-left: 1px;
            viewrecords: true
            rownumbers: true

            datatype: 'collection'
            collection: view.collection

        options = _.extend defaultOptions, options

        reader = _.extend {repeatitems: false}, options.jsonReader or {}
        options.jsonReader = reader
        if options.pager and _.isString options.pager
            options.pager = view.$ options.pager

        obj = {}
        delegateGridEvents view, obj, options, 'grid'

        buildGrid el, options, view
        obj.component = el

        if options.fit
            el.addClass 'c-jqgrid-fit'
            cbGrid.resizeToFit el

        el
    ###

    cdeio.registerComponentHandler 'tree-table', (->), (el, options, view) ->
        collection = view.collection

        options = _.extend {ExpandColumn : 'name'}, options,
            treeGrid: true
            treeGridModel: 'adjacency'
            datatype: 'tree-table-collection'
            collection: collection

        reader = _.extend {repeatitems: false}, options.jsonReader or {}
        options.jsonReader = reader
        reader = _.extend {parent_id_field: 'parentId'}, options.treeReader or {}
        options.treeReader = reader

        if options.pager and _.isString options.pager
            options.pager = view.$ options.pager

        obj = {}
        delegateGridEvents view, obj, options, 'treeTable'

        if options.fit
            el.addClass 'ui-jqgrid-fit'
            cbGrid.resizeToFit el

        # el.jqGrid options
        grid = buildGrid el, options, view
        obj.component = grid
        grid

    buildGrid = (el, options, view)->
        fields = options.colModel
        colModel = []
        for f in fields
            if f.type == 'enum'
                data = f.editoptions.value.split ';'
                f.searchoptions = sopt: ['in'],
                dataInit: (el) ->
                    _select = $('<select>')
                    _select.append "<option value=#{d.split(':')[0]}>#{d.split(':')[1]}</option>" for d in data
                    $(el).after(_select)
                    $(el).hide()
                    _select.css 'width', '100%'
                    _select.attr 'multiple', 'multiple'
                    _select.select2()
                    _select.on 'change', ->
                        $(el).val _select.val()
                        $(el).trigger 'keydown'
            else if f.type == 'date'
                f.searchoptions = sopt: ['between'],
                dataInit: (el) ->
                    $(el).daterangepicker()
            else if f.type == 'number'
                f.searchoptions = sopt: ['between']
            else if f.type == 'boolean'
                f.stype = 'select'
                f.editoptions = {value:':全部;1:是;0:否'}
            else
                f.searchoptions = sopt: ['like'] if(f.stype != 'select')
            if f.name.indexOf('.') isnt -1
                f.sortable = false
                f.search = false
            if _.isString f.renderer
                f.formatter = view.bindEventHandler f.renderer, 'renderers'
            if _.isString f.peeler
                f.unformat = view.bindEventHandler f.peeler, 'renderers'
            colModel.push f
        options.colModel = colModel
        grid = el.jqGrid options
        el.jqGrid('filterToolbar', stringResult: true, searchOnEnter: false) if options.filterToolbar is true
        grid
