define [
    'jquery'
    'underscore'
    'coala/coala'
    'coala/vendors/jquery/dataTables/jquery.dataTables'
    'coala/vendors/jquery/dataTables/jquery.dataTables.bootstrap'
], ($, _, coala) ->

    $.fn.dataTable.defaults.fnServerData = (url, data, fn, settings) ->
        view = settings.oInit.view
        d = {}
        d[item.name] = item.value for item in data
        cname = d['sColumns'].split(',')[d['iSortCol_0']]
        order = d['sSortDir_0']
        params =
            _first: d['iDisplayStart']
            _pageSize: d['iDisplayLength']
            _order: cname + '-' + order

        _.extend params, view.collection.extra

        settings.jqXHR = view.collection.fetch(data: params).done ->
            data = view.collection.toJSON()
            data = settings.oInit.afterRequest.call view, data if settings.oInit.afterRequest

            json =
                aaData: data
                iTotalRecords: view.collection.recordCount
                iTotalDisplayRecords: view.collection.recordCount

            $(settings.oInstance).trigger('xhr', [settings, json])
            fn json

    adaptColumn = (col) ->
        col = name: col, header: col if _.isString col
        o =
            bSearchable: !!col.searchable
            bSortable: col.sortable isnt false
            bVisible: col.visible isnt false
            aDataSort: col.dataSort if col.dataSort
            asSorting: col.sorting if col.sorting
            fnCreatedCell: col.cellCreated if col.cellCreated
            mRender: col.render if col.render
            iDataSort: col.dataSort if col.dataSort
            mData: col.name if col.name
            sCellType: col.cellType if col.cellType
            sClass: col.style if col.style
            sDefaultContent: col.defaultContent if col.defaultContent isnt null
            sName: col.name if col.name
            sTitle: col.header if col.header
            sType: col.type if col.type
            sWidth: col.width if col.width

    extendApi = (table, view, options) ->
        collection = view.collection
        _.extend table,
            clear: ->
                table.fnClearTable()
            addRow: (data) ->
                table.fnAddData(data)
            getSelected: ->
                selected = []
                table.find('input[type="checkbox"]:checked').each (i, item) ->
                    val = $(item).val()
                    selected.push collection.get(val) or val
                if options.multiple then selected else selected[0]
            addParam: (key, value) ->
                view.collection.extra[key] = value
            removeParam: (key) ->
                delete view.collection.extra?[key]
            refresh: (includeParams = true) ->
                table.fnDraw()

    coala.registerComponentHandler 'grid', (->), (el, options, view) ->

        opt = _.extend
            bServerSide: !options.data
            view: view
        , options.options

        el.addClass 'table'
        el.addClass options.style or 'table-striped table-bordered table-hover'

        if not opt.aoColumnDefs and not opt.aoColumns and options.columns
            columns = [].concat options.columns
            if options.checkBoxColumn isnt false
                columns.unshift
                    sortable: false, searchable: false, name: 'id', header: '', width: '25px'
                    render: (data) -> """ <input type="checkbox" id="chk-#{data}" value="#{data}" class="select-row"/> <label class="lbl"></lable> """
            if options.numberColumn is true
                columns.unshift
                    sortable: false, searchable: false, name: 'i', header: '#', width: '25px'
            opt.aoColumns = (adaptColumn col for col in columns)

        opt.aaData = options.data if options.data

        table = el.dataTable opt
        table.delegate 'tr', 'click', (e) ->
            return if $(e.target).is('input')

            t = $(e.currentTarget)
            chk = t.find 'input[type="checkbox"][id*="chk-"]:eq(0)'
            checked = chk.is(':checked')
            chk.prop('checked', !checked).trigger('change')

        table.delegate 'input[type="checkbox"][id*="chk-"]', 'change', (e) ->
            input = $(e.currentTarget)
            checked = input.is(':checked')
            tr = input.closest('tr')

            if checked and options.multiple isnt true
                table.find('input[id*="chk-"]:checked').prop('checked', false)
                table.find('tr.selected').removeClass('selected')
                input.prop('checked', true)
            tr[if checked then 'addClass' else 'removeClass']('selected')
            table.trigger 'selectionChanged', table.getSelected()

        settings = table.fnSettings()
        view.collection.extra = _.extend {}, options.params or {}
        extendApi table, view, options

        table
