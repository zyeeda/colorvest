define [
    'underscore'
    'jquery'
    'cdeio/core/form-view'
    'cdeio/core/form/form-field'
], (_, $, FormView, FormField) ->

    # 图片类型
    types = [
        'image/png'
        'image/bmp'
        'image/jpeg'
        'image/gif'
        'image/x-icon'
    ]

    # 根据 content-type 判断是否为图片
    isImage = (contentType) ->
        _.contains types, contentType
        
    class FilePickerField extends FormField
        constructor: ->
            super
            @type = 'file-picker'

        getComponent: ->
            if _.isString @options.acceptFileTypes
                @options.acceptFileTypes = new RegExp(@options.acceptFileTypes, 'i')

            _.extend
                title: '选择' + @options.label
            , @options,
                selector: 'a-' + @id
                id: 'a-' + @id
                type: @type
                name: @name
                readOnly: @readOnly

        getComponents: ->
            if @readOnly then [] else [@getComponent()]

        loadFormData: (value, data) ->
            if @readOnly
                @form.$(@id).text(value?.name)
                @value = value
                if @multiple is true
                    for item in @value
                        @previewSingle @options, item.id, item.id, item.id, @options.url, item.contentType
                else
                    @previewSingle @options, @id, @value.id, @id, @options.url, @value.contentType
            else
                picker = @form.findComponent('a-' + @id)
                return unless picker
                picker.loadData data 

        previewSingle: (options, did, rid, $id, url, contentType) ->
            # 只有图片类型，才能预览
            return if isImage(contentType) is false
            _url = url + '/' + rid

            @form.$('preview-' + did).attr('href', 'javascript: void 0')
            @form.$('preview-' + did).click (e) =>
                id = $(e.target).attr('id').match(/preview-(.*)$/)[1]
                # console.log $(e.target).attr('id').match(/preview-(.*)$/)
                popover = @form.$('popover-span-' + id)
                @popoverToggle popover, _url, id

        popoverToggle: (popover, url, id) ->
            _next = popover.next()
            if _next.hasClass('popover') && _next.css('display') == 'block'
                _next.hide()
            else
                $('a[id*="popover-span"]').each (e) ->
                    if $(this).data('popover')
                        $(this).next().hide()
                popover.attr('data-content', popover.attr 'data-content')
                popover.popover html: true
                popover.popover 'show'
                $('#preview-img-' + id).click =>
                        @popoverToggle popover, url, id
                        window.open url, id
        getFormData: ->
            if @readOnly
                @value?.id
            else
                field = @form.findComponent('a-' + @id)
                return unless field
                obj = field.getFormData()

                if field.options.multiple
                    return if obj.length == 0 then id: null else obj
                return obj if obj and obj.id
                id: null

                        # <a target="_blank" style="word-break:break-all;" href="<%= options.url %>/{{id}}">{{filename}}</a>
        getTemplateString: -> '''
            <% if (readOnly) { %>
                <div class="c-view-form-field">
                    <% if (!hideLabel) { %>
                    <div class="field-label"><%= label %></div>
                    <% } %>
                    <div id="<%= id %>" class="field-value">
                        <% if (options.multiple) { %>
                        {{#each <%= name %>}}
                        <a id="popover-span-{{id}}" class="upload-preview-btn upload-multiple-preview" href="javascript: void(0) "  data-rel="popover" data-placement="right"  data-content="<img id='preview-img-{{id}}' class='upload-preview' src='<%= options.url %>/{{id}}' />">&nbsp;</a>
                        <a id="preview-{{id}}" target="_blank" style="z-index: 1;position: relative;" href="<%= options.url %>/{{id}}">{{filename}}</a>
                        </br>
                        {{/each}}
                        <% } else { %>
                        <a id="popover-span-<%= id %>" class="upload-preview-btn upload-multiple-preview" href="javascript: void(0) "  data-rel="popover" data-placement="right"  data-content="<img id='preview-img-<%= id %>' class='upload-preview' src='<%= options.url %>/{{<%= name %>.id}}' />">&nbsp;</a>
                        <a id="preview-<%= id %>" target="_blank" style="z-index: 1;position: relative;" href="<%= options.url %>/{{<%= name %>.id}}">{{<%= name %>.filename}}</a>
                        <% } %>
                    </div>
                </div>
            <% } else { %>
                <div class="control-group">
                  <% if (!hideLabel) { %>
                  <label class="control-label" for="<%= id %>"><%= label %><% if (required) { %>
                        <span class="required-mark">*</span>
                    <% } %></label><% } %>
                  <div class="controls">
                    <div id="a-<%= id %>"></div>
                  </div>
                </div>
            <% } %>
        '''

    FormField.add 'file-picker', FilePickerField
