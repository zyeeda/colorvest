define [ 'jquery'
    'underscore'
    'cdeio/cdeio'
    'cdeio/vendors/jquery/dataTables/jquery.dataTables'
    'cdeio/vendors/jquery/dataTables/jquery.dataTables.bootstrap'
    'cdeio/vendors/jquery/dataTables/jquery.dataTables.columnFilter'
    'cdeio/vendors/jquery/dataTables/FixedHeader'
    #'cdeio/vendors/jquery/dataTables/ColReorderWithResize'
], ($, _, cdeio) ->

    searchExp = /^sSearch_(\d+)$/
    typeMap =
        select: 'eq', text: 'like', number: 'eq'
        'number-range': 'between', 'date-range': 'between'

    extractFilters = (data, settings) ->
        filters = []
        columns = data['sColumns'].split(',')
        separator = data['sRangeSeparator']
        for key, value of data
            m = key.match searchExp
            continue if not m or not value
            type = settings.oInit.filters?[m[1]]?.type
            continue if not type
            op = typeMap[type]
            if op is 'between'
                value = value.split separator
                continue if not value[0] and not value[1]
                filters.push [op, columns[m[1]], value[0], value[1]]
            else
                filters.push [op, columns[m[1]], value]
        if filters.length is 0 then null else filters

    $.fn.dataTable.defaults.fnServerData = (url, data, fn, settings) ->
        view = settings.oInit.view
        d = {}
        d[item.name] = item.value for item in data

        cname = d['sColumns'].split(',')[d['iSortCol_0']]
        order = d['sSortDir_0']
        sortable = d['bSortable_' + d['iSortCol_0']]
        params =
            _first: d['iDisplayStart']
            _pageSize: d['iDisplayLength']
            _order: cname + '-' + order
        delete params['_order'] unless sortable
        params['_order'] = settings.oInit.defaultOrder if not params['_order'] and settings.oInit.defaultOrder
        _.extend params, view.collection.extra

        if params['_pageSize'] is -1
            delete params['_first']
            delete params['_pageSize']

        filters = extractFilters d, settings
        if filters and params['_filters']
            params._filters = (v for k, v of params._filters).concat filters
        else if filters
            params['_filters'] = filters
        else if params._filters
            params._filters = (v for k, v of params._filters)

        settings.jqXHR = view.collection.fetch(data: params).done ->
            data = view.collection.toJSON()
            data = settings.oInit.afterRequest.call view, data if settings.oInit.afterRequest
            d['_i'] = (i+1) for d, i in data

            json =
                aaData: data
                iTotalRecords: view.collection.recordCount
                iTotalDisplayRecords: view.collection.recordCount

            $(settings.oInstance).trigger('xhr', [settings, json])
            fn json

    adaptColumn = (col, view) ->
        col = name: col, header: col if _.isString col
        o =
            bSearchable: !!col.searchable and col.name.lastIndexOf('.') is -1
            bSortable: col.sortable isnt false and col.name.lastIndexOf('.') is -1
            bVisible: col.visible isnt false
            aDataSort: col.dataSort if col.dataSort
            asSorting: col.sorting if col.sorting
            fnCreatedCell: col.cellCreated if col.cellCreated
            mRender: col.pattern if col.pattern
            iDataSort: col.dataSort if col.dataSort
            mData: col.name if col.name
            sCellType: col.cellType if col.cellType
            sClass: col.style if col.style
            sDefaultContent: col.defaultContent or ''
            sName: col.name if col.name
            sTitle: col.header if col.header
            sType: col.type if col.type
            sWidth: col.width if col.width
        if col.renderer
            if _.isFunction col.renderer
                o.mRender = col.renderer
            else
                if view.feature.baseName is 'inline-grid'
                    scaffold = view.feature.startupOptions.gridOptions.form.feature.options.scaffold or {}
                    renderers = scaffold.inlineGridPickerRenderers or {}
                else
                    scaffold = view.feature.options.scaffold or {}
                    renderers = scaffold.renderers or {}

                throw new Error("no renderer can be found in name: #{col.renderer}") if not renderers[col.renderer]
                o.mRender = _.bind renderers[col.renderer], view
        o

    extendApi = (table, view, options) ->
        collection = view.collection
        _.extend table,
            clear: ->
                table.fnClearTable()
            addRow: (data) ->
                table.fnAddData(data)
            getSelected: ->
                return table.selectNodes if options.multiple && options.crossPage
                selected = []
                table.find('input[id*="chk-"]:checked').each (i, item) ->
                    val = $(item).val()
                    selected.push collection.get(val) or val
                return null if selected.length is 0
                if options.multiple then selected else selected[0]
            getSelectedIndex: ->
                selected = []
                table.find('input[id*="chk-"]:checked').each (i, item) ->
                    selected.push table.fnGetPosition item.parentNode.parentNode
                return null if selected.length is 0
                if options.multiple then selected else selected[0]
            getSelectedTrs: ->
                selected = []
                table.find('input[id*="chk-"]:checked').each (i, item) ->
                    selected.push $(item).parent().parent()
                selected
            removeSelectedRow: ->
                selectedTrs = []
                idx = table.getSelectedIndex()
                return unless idx?
                if options.multiple
                    selectedTrs = table.getSelectedTrs()
                    for tr in selectedTrs
                        table.fnDeleteRow $(tr)[0]
                        # true
                else
                    table.fnDeleteRow idx
            removeSelectedNodes: ->
                table.selectNodes = undefined if options.crossPage && options.multiple
            addParam: (key, value) ->
                view.collection.extra[key] = value
            addFilter: (filter) ->
                view.collection.extra._filters or= {}
                view.collection.extra._filters[filter[1]] = filter
            addFilters: (filters = []) ->
                @addFilter filter for filter in filters
            removeFilter: (filter) ->
                view.collection.extra._filters or= {}
                delete view.collection.extra._filters[filter[1]]
            removeFilters: (filters = []) ->
                @removeFilter filter for filter in filters
            removeParam: (key) ->
                delete view.collection.extra?[key]
            refresh: (includeParams = true) ->
                table.fnDraw()

    changeNodes = (view, table, nodes, status, op) ->
        collections = []
        _.each _.toArray(nodes), (n) ->
            collections.push view.collection.get n.value
        if status
            table.selectNodes = if table.selectNodes && table.selectNodes.length > 0 then  _.union table.selectNodes, collections else collections
            if op = 'all'
                table.selectNodes = _.uniq table.selectNodes, false, (obj) ->
                    obj.id
        else
            _.each collections, (k) ->
                _.each table.selectNodes, (n, i) ->
                    if n && n.id == k.id
                        table.selectNodes.splice i, 1

    cdeio.registerComponentHandler 'grid', (->), (el, options, view) ->

        opt = _.extend
            sDom: if options.paginate is false then "<'c-grid-body't>" else "Rs<'row-fluid c-grid-top'<'span6'i><'span6'p>><'c-grid-body't>",
            bServerSide: !options.data
            # bServerSide: true # false 则不向后台发送数据请求
            bPaginate: options.paginate isnt false
            view: view
            defaultOrder: options.defaultOrder
            oLanguage:
                sInfo: '显示 _START_ - _END_ 条, 共 _TOTAL_ 条'
                sEmptyTable: '没有相关记录'
                sInfoEmpty: '显示 0 - 0 条, 共 0 条'
                sZeroRecords: '没有相关记录'
            bSortCellsTop: true
        , options.options

        el.addClass 'table'
        el.addClass options.style or 'table-striped table-bordered table-hover'

        if not opt.aoColumnDefs and not opt.aoColumns and options.columns
            columns = [].concat options.columns
            if options.checkBoxColumn isnt false
                columns.unshift
                    sortable: false
                    searchable: false
                    name: 'id'
                    header: if options.multiple then '<input type="checkbox" class="select-all" id="check-all-' + view.cid + '"> <label class="lbl"/>' else ''
                    width: '25px'
                    renderer: (data, type, row, a) ->
                        if row['__FORM_TYPE__'] == 'delete'
                            return """
                            <input type="hidden" id="chk-#{data}" value="#{data}" class="select-row" name="chk-#{view.cid}" />
                            <span class="red-fork">×</lable>
                            """
                        """
                            <input type="#{if options.multiple then 'checkbox' else 'radio'}"
                            id="chk-#{data}" value="#{data}" class="select-row" name="chk-#{view.cid}"/>
                            <label class="lbl"></lable>
                        """
            if options.numberColumn is true
                columns.unshift
                    sortable: false, searchable: false, name: '_i', header: '#', width: '25px'
            filterEnabled = false
            filters = []
            footers = []
            opt.aoColumns = for col in columns
                if col.filter
                    filterEnabled = true
                    filters.push type: col.filter, values: col.source
                else
                    filters.push null
                footers.push "<th></th>"
                adaptColumn col, view


        opt.aaData = options.data if options.data
        opt.iDeferLoading = options.deferLoading if _.has options, 'deferLoading'

        opt.oColReorder =
            allowReorder: false
            allowResize: true

        if filterEnabled
            el.prepend "<thead><tr>#{footers.join('')}</tr><tr>#{footers.join('')}</tr></thead>"
            opt.filters = filters

        if options.fixedHeader isnt false
            opt.sScrollY = options.scrollY or '350'

        table = el.dataTable opt

        checkAllSelector = 'input#check-all-' + view.cid
        table.delegator = table.parents('div.c-grid-body')
        checkAll = table.delegator.find checkAllSelector

        table.delegator.delegate checkAllSelector, 'change.deletage', (e) ->
            checked = checkAll.is ':checked'

            table.find('input[id*="chk-"]').prop 'checked', checked
            table.trigger 'selectionChanged', [table.getSelected()]
            changeNodes view, table, table.find('input[id*="chk-"]'), checked, 'all' if options.crossPage && options.multiple

        table.delegator.delegate 'tr', 'click.deletage', (e) ->
            return if $(e.target).is('input')

            t = $(e.currentTarget)
            chk = t.find 'input[id*="chk-"]:eq(0)'
            return if chk.is(':disabled')
            checked = chk.is(':checked')
            chk.prop('checked', !checked).trigger('change')

        table.delegator.delegate 'input[id*="chk-"]', 'change.delegate', (e) ->
            input = $(e.currentTarget)
            checked = input.is(':checked')
            tr = input.closest('tr')

            if checked and options.multiple isnt true
                table.find('input[id*="chk-"]:checked').prop('checked', false)
                table.find('tr.selected').removeClass('selected')
                input.prop('checked', true)
            if options.multiple
                allSelected = true
                table.find('input[id*="chk-"]').each (i, item) ->
                    allSelected = false if not $(item).is(':checked')
                checkAll.prop 'checked', allSelected
            tr[if checked then 'addClass' else 'removeClass']('selected')
            table.trigger 'selectionChanged', [table.getSelected()]
            changeNodes view, table, [input[0]], checked, 'one' if options.crossPage && options.multiple

        settings = table.fnSettings()
        view.collection.extra = _.extend {}, options.params or {}
        extendApi table, view, options

        table.columnFilter sPlaceHolder: 'head:after', aoColumns: filters, sRangeFormat: '{from} - {to}' if filterEnabled

        if options.crossPage && options.multiple
            table.on 'processing.dt', (e) ->
                if table.selectNodes
                    _.each table.selectNodes, (n, i) ->
                        table.find('#chk-' + n.id).attr('checked', true)

        table.dispose = ->
            table._oPluginFixedHeader?.fnDestroy()
            table.fnDestroy(true)
            table.delegator.unbind '.delegate'

        table
