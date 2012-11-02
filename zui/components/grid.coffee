
define [
    'underscore'
    'zui/coala'
    'libs/zui/components/callbacks/grid'
    'order!libs/jquery/jqgrid/i18n/grid.locale-cn'
    'order!libs/jquery/jqgrid/jquery.jqGrid.src'
], (_, coala, cbGrid) ->

    coala.registerComponentHandler 'grid', (->), (el, options, view) ->

        defaultOptions =
            autowidth: options.fit
            cellLayout: 11 # padding: 0 5px; border-left: 1px;
            viewrecords: true
            rownumbers: true

            datatype: 'collection'
            collection: view.collection

        options = _.extend defaultOptions, options

        reader = _.extend {repeatitems: false}, options.jsonReader or {}
        options.jsonReader = reader
        if options.pager and _.isString options.pager
            options.pager = view.$ options.pager

        events = [
            'onSelectRow'
            'gridComplete'
            'beforeRequest'
        ]
        for event in events
            do (event) ->
                if options[event]
                    options[event] = _.bind (name, args...) ->
                        method = @eventHandlers[name]
                        throw new Error('no handler is named ' + name) if not _.isFunction method

                        method.apply view, args
                    , view, options[event]

        if options.fit
            el.addClass 'ui-jqgrid-fit'
            cbGrid.resizeToFit el

        # el.jqGrid options
        buildGrid el, options, view

    coala.registerComponentHandler 'tree-table', (->), (el, options, view) ->
        collection = view.collection

        options = _.extend {ExpandColumn : 'name'}, options
        options.treeGrid = true
        options.ExpandColumn = 'name'
        options.treeGridModel = 'adjacency'

        processRecords = (records, parent, level, results) ->
            rs = []
            if parent is null
                for record in records
                    rs.push record if record.parent is null
            else
                for record in records
                    rs.push record if record.parent?.id is parent.id

            if rs.length is 0
                parent.isLeaf = true if parent
                return

            for r in rs
                r.level = level
                r.expanded = false
                r.loaded = true
                r.isLeaf = false
                r.parentId = if parent is null then null else parent.id
                results.push r
                processRecords records,  r, level + 1, results

        if options.datatype isnt 'local'
            options.datatype = (data) ->
                op = {data: data}

                op.data['_page'] = data.page if data.page
                op.data['_pageSize'] = data.rows if data.rows
                op.data['_order'] = "#{data.sidx}-#{data.sord}" if data.sidx

                delete data.page
                delete data.rows
                delete data.sidx
                delete data.sord

                collection.fetch(op).done =>
                    records = collection.toJSON()
                    rs = []
                    processRecords records, null, 0, rs
                    @addJSONData rows: rs, total: collection.pageCount, page: collection.page

        reader = _.extend {repeatitems: false}, options.jsonReader or {}
        options.jsonReader = reader
        reader = _.extend {parent_id_field: 'parentId'}, options.treeReader or {}
        options.treeReader = reader

        if options.pager and _.isString options.pager
            options.pager = view.$ options.pager

        events = [
            'onSelectRow'
            'gridComplete'
        ]
        for event in events
            do (event) ->
                if options[event]
                    options[event] = _.bind (name, args...)->
                        method = @eventHandlers[name]
                        throw new Error('no handler is named ' + name) if not _.isFunction method

                        method.apply view, args
                    , view, options[event]

        if options.fit
            el.addClass 'ui-jqgrid-fit'
            cbGrid.resizeToFit el

        # el.jqGrid options
        buildGrid el, options, view

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
            colModel.push f
        options.colModel = colModel
        grid = el.jqGrid options
        el.jqGrid 'filterToolbar', stringResult: true, searchOnEnter: false
        grid
