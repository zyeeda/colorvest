define [
    'underscore'
    'jquery'
    'coala/coala'
    'coala/core/view'
    'handlebars'
], (_, $, coala, View, H) ->

    class PickerChooser
        constructor: (@picker) ->
            @feature = picker.view.feature
            @module = @feature.module
            @app = @module.getApplication()
            @view = @generateView()
            @view.eventHandlers = @getViewHandlers()

        generateView: ->
            tpl = H.compile @getViewTemplate()
            options =
                feature: @feature
                module: @module
                baseName: 'picker-chooser'
                model: @picker.options.url
                components: @getViewComponents()
                events: @getViewEvents()
                avoidLoadingHandlers: true
                extend:
                    renderHtml: (su, data) ->
                        tpl data

            @verifyViewOptions options

            new View options

        getViewTemplate: ->
            '<table id="grid"></table>'

        getViewComponents: ->
            grid = _.extend {}, @picker.options.grid,
                type: 'grid'
                selector: 'grid'
            ,
                if @picker.options.multiple is true then multiselect: true else {}

            [grid]

        getViewEvents: -> {}
        getViewHandlers: -> {}

        verifyViewOptions: (options) ->

        getSelectedItems: ->
            grid = @view.components[0]

            if @picker.options.multiple is true
                selected = grid.getSelected()
            else
                selected = [grid.getSelected()]

            if selected
                items = []
                for model in selected
                    items.push model.toJSON()
                items
            else
                false

        show: ->
            @app.showDialog
                title: @picker.options.title
                view: @view
                buttons: [
                    label: @picker.options.buttonLabel or '确定'
                    status: 'btn-primary'
                    fn: =>
                        selected = @getSelectedItems()
                        return false if not selected
                        selected = selected[0] if not @picker.options.multiple
                        @picker.setValue selected
                ]

    class Picker
        constructor: (@options = {}) ->
            @id = options.id or _.uniqueId 'picker'
            @name = options.name
            @value = options.value
            @text = options.text or @value
            @container = options.container
            @view = options.view
            @triggerClass = options.triggerClass

            if options.chooser
                @chooser = options.chooser
            else
                Type = options.chooserType or PickerChooser
                @chooser = new Type @

        getFormData: ->
            id = @options.toValue or (data) -> data.id
            if _.isArray @value
                (id item for item in @value)
            else
                id @value or {}

        setText: (text) ->
            @text = text
            if @renderred is true
                @container.find('#text-' + @id).html text

        setValue: (value) ->
            text = @options.toText or (data) -> if data then data.name else ''
            #text = @options.toText or (data) -> data.name
            if _.isArray value
                t = (text item for item in value).join ','
            else
                t = text value
            @setText t
            @value = value

        loadData: (data) ->
            @setValue if @name then data[name] else data

        getTemplate: -> _.template '''
            <div class="c-picker">
                <span class="uneditable-input"><span class="text" id="text-<%= id %>"><%= text %></span>
                    <a id="trigger-<%= id %>" class="btn pull-right <%= triggerClass %>"><i class="icon-search"/></a>
                </span>
            </div>
            '''
        render: ->
            return if @renderred
            @renderred = true

            @container.html @getTemplate() @
            @container.find('#trigger-' + @id).click =>
                @chooser.show(@)

    Picker: Picker
    Chooser: PickerChooser
