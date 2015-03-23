define [
    'jquery'
    'underscore'
    'cdeio/core/form/form-field'
], ($, _, FormField) ->

    class FormGroup
        constructor: (@form, @options, @fieldOptions) ->
            @options = options = name: options if _.isString options
            @cols = @options.columns if @options.columns
            @fieldOptions = fieldOptions = [fieldOptions] if not _.isArray fieldOptions
            @containerId = _.uniqueId 'group'

            @visible = @options.visible isnt false
            @hiddenFields = []
            @fields = []
            for field in fieldOptions
                if @options.readOnly is true
                    field = name: field, type: 'text' if _.isString field
                    field.readOnly = true
                if @options.disabled is true
                    field.disabled = true
                (if field.type is 'hidden' then @hiddenFields else @fields).push FormField.build field, @, form


        getColumns: ->
            if not @cols
                @cols = 1
                @cols = 2 for field in @fields when field.colspan is 2
            throw new Error "unsupported columns:#{@cols}, only can be: 1, 2, 3, 4, 6, 12" if 12 % @cols isnt 0
            @cols

        # getTemplateString: -> '''
        #     <fieldset id="<%= containerId %>" class="c-form-group-cols-<%= columns %>" style="<% if (!visible) {%>display:none<%}%>">
        #         <% if (label) { %>
        #         <legend><span class="label label-info arrowed-in arrowed-in-right"><%= label %></span></legend>
        #         <% } %>
        #         <%= groupContent %>
        #     </fieldset>
        # '''
        # <div style="height:35px; background: #20252B; color: #B6C2C9;margin-top:10px;">
        #     <div><h5><%= label %></h5></div>
        # </div>
                        # <legend style="height:35px; background: #20252B; color: #B6C2C9;">
                        #     <h5 style="padding-top:5px; padding-left:12px;" ><%= label %></h5>
                        # </legend>
        # ---------
        # <% if (isInlineGrid == true) {%>
        #     <%= groupContent %>
        # <%} else {%>
        #     <fieldset id="<%= containerId %>" class="c-form-group-cols-<%= columns %>" 
        #         <% if (label||single==false) { %>  
        #             style="border:1px solid #BAC1C8;<% if (index!=0) {%> margin-top:20px;<% } %> 
        #         <% } %>
        #         <% if (!visible) {%>display:none<%}%>">
        #         <% if (label) { %>
        #             <div style="height:35px; background: #20252B; color: #B6C2C9;">
        #                 <h5 style="padding-top:5px; padding-left:12px;margin:0" ><%= label %></h5>
        #             </div>
        #             <div style="padding: 15px;" >
        #                 <%= groupContent %>
        #             </div>
        #         <% } else{ %>
        #             <% if (single == true) { %>
        #                 <%= groupContent %>
        #             <% } else {%>
        #                 <div style="padding: 15px;" >
        #                     <%= groupContent %>
        #                 </div>                        
        #             <% } %>
        #         <% } %>
        #     </fieldset>
        # <%}%>
        getTemplateString: -> '''
            <% if (isInlineGrid == true) {%>
                <%= groupContent %>
            <%} else {%>
                <fieldset id="<%= containerId %>" class="c-form-group-cols-<%= columns %> 
                    <% if (label||single==false) { %>  
                        c-form-group-border 
                        <% if (index!=0) {%> c-form-group-margin <% } %>
                    <% } %>
                    "
                    <% if (!visible) {%>style="display:none"<%}%> 
                    >
                    <% if (label) { %>
                        <div class="c-form-group-title">
                            <h5><i class="icon-file-text" style="margin-right: 5px;"></i><%= label %></h5>
                        </div>
                        <div class="c-form-group-container" >
                            <%= groupContent %>
                        </div>
                    <% } else{ %>
                        <% if (single == true) { %>
                            <%= groupContent %>
                        <% } else {%>
                            <div class="c-form-group-container" >
                                <%= groupContent %>
                            </div>                        
                        <% } %>
                    <% } %>
                </fieldset>
            <%}%>
        '''
        setVisible: (visible) ->
            @visible = if visible is false then false else true
            @form.$(@containerId)[if @visible then 'show' else 'hide']()
            field.setVisible @visible for field in @fields

        getRowTemplate: -> _.template '''
            <% if (isInlineGrid==true){%>
                <% if (single==true){%>
                    <%= items %>
                <% } else {%>
                    <fieldset class="c-form-group-cols-1 c-form-group-border <% if (index!=0) {%> c-form-group-margin <% } %>" >
                        <%= items %>
                    </fieldset>
                <% } %>
            <% } else {%>
                <div class="row-fluid"><%= items %></div>
            <% } %>
        '''
        getItemTemplate: ->_.template  '''
            <% if (isInlineGrid==false){%>
                <div class="span<%= span %>" > <%= field %></div>
            <% } else { %>
                <%= field %>
            <% } %>
        '''

        getTemplate: (single = false, index) ->
            return '' if _.isEmpty @fields

            contents = []
            columns = @getColumns()
            span = 12 / columns
            row = []

            isInlineGrid = false
            isInlineGrid = true for field in @fields when field.type is 'inline-grid'

            newRow = (isInlineGrid) =>
                contents.push @getRowTemplate() 
                    isInlineGrid: isInlineGrid
                    containerId: @containerId
                    single: single
                    index: index
                    items: row.join('')
                row = []
            # console.log '----fields : ', @fields

            for field, i in @fields
                colspan = field.colspan or 1
                colspan = columns if colspan > columns

                newRow(isInlineGrid) if row.length + colspan > columns
                row.push @getItemTemplate() 
                    isInlineGrid: isInlineGrid
                    span: colspan * span
                    field: field.getTemplate()
                row.push '' for i in [1...colspan]
                newRow(isInlineGrid) if row.length is columns
            newRow(isInlineGrid) if row.length > 0

            opts = 
                label: @options.label
                groupContent: contents.join('')
                containerId: @containerId
                columns: @getColumns()
                visible: @visible
                isInlineGrid: isInlineGrid
                single: single
                index: index

            console.log 'opts', opts
            # console.log 'getTemplateString', @getTemplateString()
            _.template(@getTemplateString())(opts)


        getHiddenFieldsTemplate: ->
            (field.getTemplate() for field in @hiddenFields).join ''
