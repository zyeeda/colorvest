define [
    'underscore'
    'jquery'
    'cdeio/cdeio'
    'cdeio/components/picker-base'
    'cdeio/components/jqgrid'
], (_, $, cdeio, Picker) ->

    class TreePickerChooser extends Picker.Chooser
        getViewTemplate: ->
            '<ul id="tree" class="ztree"></ul>'
        getViewComponents: ->
            tree =
                type: 'tree'
                selector: 'tree'
                data:
                    simpleData:
                        enable: true

            if @picker.options.multiple is true
                tree.check = enable: true
                if @picker.options.tree and @picker.options.tree.check
                    tree.check = _.extend @picker.options.tree.check, tree.check
            else
                tree.check = 
                    enable: true
                    chkStyle: 'radio'
                    radioType: 'all'
                if @picker.options.tree and @picker.options.tree.check
                    tree.check = _.extend @picker.options.tree.check, tree.check
            [tree]
        getSelectedItems: ->
            tree = @view.components[0]
            selected = tree.getCheckedNodes()
            return false if selected.length is 0
            selected

    class ManyPicker extends Picker.Picker
        getTemplate: -> _.template '''
            <div>
              <a href="javascript:void 0" class="btn" id="trigger-<%= id %>"><i class="icon-search"/></a>
              <a href="javascript:void 0" class="btn" id="remove-<%= id %>"><i class="icon-remove"/></a>
              <table id="grid-<%= id %>"></table>
            </div>
        '''
        render: ->
            super
            @grid = @container.find('#grid-' + @id).jqGrid @options.pickerGrid

            @container.find('#remove-' + @id).click =>
                selected = @grid.getGridParam("selrow")
                return if not selected
                @grid.delRowData selected
        setValue: (value) ->
            return if not value
            value = [value] if not _.isArray value
            for v in value
                continue if _.include(@grid.getDataIDs(), v.id)
                @grid.addRowData v.id, v
        getFormData: ->
            @grid.getDataIDs()

    fn = (pickerType, chooserType, el, opt = {}, view) ->
        app = view.feature.module.getApplication()
        options = _.extend opt,
            view: view
            container: el
            chooserType: chooserType
        if options.remoteDefined
            deferred = $.Deferred()
            $.get view.feature.module.getApplication().url(options.url + '/configuration/picker'), (data) ->
                options = _.extend options, data
                picker = new pickerType options
                picker.render()
                deferred.resolve picker
            deferred
        else
            picker = new pickerType options
            picker.render()
            picker

    # :TODO mutil-grid-picker multi-tree-picker 可以用inline-grid替代， 后期重构是否考虑去掉
    cdeio.registerComponentHandler 'grid-picker', (->), _.bind(fn, @, Picker.Picker, Picker.Chooser)
    cdeio.registerComponentHandler 'tree-picker', (->), _.bind(fn, @, Picker.Picker, TreePickerChooser)
    cdeio.registerComponentHandler 'multi-grid-picker', (->), _.bind(fn, @, ManyPicker, Picker.Chooser)
    cdeio.registerComponentHandler 'multi-tree-picker', (->), _.bind(fn, @, ManyPicker, TreePickerChooser)
