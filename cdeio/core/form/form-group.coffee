define [
    'jquery'
    'underscore'
    'cdeio/core/form/form-field'
], ($, _, FormField) ->

    class FormGroup
        constructor: (form, options, fieldOptions) ->
            @form = form
            @options = options
            @fieldOptions = fieldOptions

            @options = {name: @options} if _.isString @options
            @fieldOptions = [@fieldOptions] if not _.isArray @fieldOptions
            @containerId = _.uniqueId 'group'
            @visible = @options.visible isnt false

            @hiddenFields = []
            hiddenFieldOpts = []
            @fields = []
            fieldOpts = []

            for field in @fieldOptions
                field = {name: field, type: 'text'} if _.isString field
                field.readOnly = true if @options.readOnly is true
                field.disabled = true if @options.disabled is true
                (if field.type is 'hidden' \
                    then hiddenFieldOpts else fieldOpts).push field

            if fieldOpts.length is 1
                f = fieldOpts[0]
                f.hideLabel = true
                f.isTheOnlyField = true

            for field in fieldOpts
                @fields.push FormField.build field, this, form
            for field in hiddenFieldOpts
                @hiddenFields.push FormField.build field, this, form

            @columns = @options.columns or 1
            @columns = 2 if _.some @fields, (f) -> f.colspan is 2
            # OMG, how can you support 3, 4, 6 and 12 columns?
            throw new Error \
                "Unsupported columns: #{@columns}, \
                only can be: 1, 2, 3, 4, 6, 12" \
                if 12 % @columns isnt 0

        setVisible: (visible) ->
            @visible = not not visible
            @form.$(@containerId)[if @visible then 'show' else 'hide']()
            field.setVisible @visible for field in @fields

        # REFACTOR: getTemplate and getTemplateString method names are
        #           confused. getTemplateString should be getTemplate, and
        #           getTemplate should be getContent or something similar.
        getTemplateString: -> '''
            <fieldset
                id="<%= containerId %>"
                class="c-form-group-cols-<%= columns %>"
                <% if (!visible) { %>style="display:none;"<% } %>
            >
                <% if (label) { %>
                    <legend class="c-form-group-label">
                        <h5>
                            <i class="<%= labelIcon %> c-form-group-label-icon"></i>&nbsp;<%= label %>
                        </h5>
                    </legend>
                <% } %>
                <div class="c-form-group-content">
                    <%= groupContent %>
                </div>
            </fieldset>
        '''

        getRowTemplate: -> _.template '''
            <div class="row-fluid"><%= items %></div>
        '''

        getItemTemplate: -> _.template '''
            <% if (isInlineGrid || isMultiFilePicker) { %>
                <%= field %>
            <% } else { %>
                <div class="span<%= span %>"><%= field %></div>
            <% } %>
        '''

        # I don't think these two params are necessary.
        #
        # @param [single] wheather the group is the only group
        # @param [index] the group index of the form
        getTemplate: (single = false, index) ->
            return '' if _.isEmpty @fields

            contents = []
            row = []
            spanPerColumn = 12 / @columns

            generateNewRow = (opts) =>
                contents.push @getRowTemplate()
                    isInlineGrid: opts.isInlineGrid
                    isMultiFilePicker: opts.isMultiFilePicker
                    containerId: @containerId
                    items: row.join ''
                row = []

            # REFACTOR: Optimize the algorithm to use some counter to count the
            #           colspan instead of the tricky [1...colspan].
            for field, i in @fields
                colspan = field.colspan or 1
                throw new Error \
                    'field.colspan cannot be greater than group.columns' \
                    if colspan > @columns

                isInlineGrid = field.type is 'inline-grid'
                isMultiFilePicker = \
                    field.type is 'file-picker' and field.multiple is true

                opts =
                    isInlineGrid: isInlineGrid
                    isMultiFilePicker: isMultiFilePicker

                generateNewRow opts if row.length + colspan > @columns
                row.push @getItemTemplate()
                    isInlineGrid: isInlineGrid
                    isMultiFilePicker: isMultiFilePicker
                    hasOnlyOneField: @hasOnlyOneField
                    span: colspan * spanPerColumn
                    field: field.getTemplate()

                # This statement inserts a placeholder when colspan is greater
                # than 1.
                #
                # E.g. colspan is 2, the above row.push inserts a field
                # template, but since the colspan is 2, so I need an empty
                # field template to take the hole.
                row.push '' for i in [1...colspan]
                generateNewRow opts if row.length is @columns
            generateNewRow opts if row.length > 0

            opts =
                label: @options.label
                labelIcon: @options.labelIcon or 'icon-file-text'
                groupContent: contents.join ''
                containerId: @containerId
                columns: @columns
                visible: @visible

            _.template(@getTemplateString())(opts)

        getHiddenFieldsTemplate: ->
            (field.getTemplate() for field in @hiddenFields).join ''
