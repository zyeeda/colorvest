define [
    'underscore'
    'jquery'
    'cdeio/cdeio'
    'cdeio/components/picker-base'
    'handlebars'
    'cdeio/vendors/jquery/fileupload/jquery.iframe-transport'
    'cdeio/vendors/jquery/fileupload/jquery.fileupload'
    'cdeio/vendors/jquery/fileupload/jquery.fileupload-process'
    'cdeio/vendors/jquery/fileupload/jquery.fileupload-validate'
], (_, $, cdeio, Picker, H) ->

    units = ['B', 'Kb', 'Mb', 'Gb', 'Tb']
    calcSize = (size) ->
        i = 0
        while size > 1024
            size = size / 1024
            i++
        size.toFixed(2) + ' ' + units[i]
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

    row = H.compile '''
        <tr>
            <td style="text-align: center;"><input id="check-{{id}}" type="checkbox" /></td>
            <td>
                <div class="progress" style="margin-bottom: 0px; margin-top: 5px;">
                    <div class="bar" id="bar-{{id}}" style="width:1%; color: black;text-align:left;">&nbsp;&nbsp;{{name}}</div>
                </div>
            </td>
            <td>
                {{#preview}}
                <a id="popover-span-{{../id}}" class="upload-preview-btn upload-multiple-preview" href="javascript: void 0"  data-rel="popover" data-placement="{{../preview}}">&nbsp;</a>
                {{#if ../isImageFile }}
                <a id="preview-{{../../id}}" href="javascript: void 0" style="z-index: 1;position: relative;">预览</a>
                &nbsp;
                {{/if}}
                <a id="download-{{../id}}" target="_blank" href="./{{../url}}" style="z-index: 2;position: relative;">下载</a>
                {{/preview}}
            </td>
        </tr>
    '''

    class FilePicker extends Picker.Picker
        getTemplate: ->
            if @options.multiple is true
                _.template '''
                    <div class="upload btn-toolbar">
                        <a id="trigger-<%= id %>" class="btn btn-small icon-cloud-upload">上传</a>
                        <a id="remove" href="javascript: void 0" class="btn btn-danger btn-small icon-minus">删除</a>
                    </div>

                    <input type="file" style="display:none" multiple="true" id="hidden-input-<%= id %>"/>
                    <div id="grid_wrapper" class="dataTables_wrapper" role="grid">
                        <div class="c-grid-body">
                            <table style="width: 100%;" id="view416-grid" class="table table-striped table-bordered table-hover dataTable">
                                <thead>
                                <tr role="row">
                                    <th class="sorting_disabled" tabindex="0" rowspan="1" colspan="1" aria-label="" style="width: 25px; text-align: center !important;"><input id="checkbox" type="checkbox"/></th>
                                    <th class="sorting" tabindex="0" rowspan="1" colspan="1" aria-label="文件名: activate to sort column ascending">文件名</th>
                                    <th class="sorting" tabindex="0" rowspan="1" colspan="1" aria-label="操作: activate to sort column ascending">操作</th>
                                </tr>
                                </thead>
                                    <tbody id="files-container-<%= id %>" role="alert"></tbody>
                            </table>
                        </div>
                    </div>
                '''
                    # <table class="table table-striped table-bordered table-hover dataTable">
                    #     <thead><tr style="height: 45px;">
                    #     <th style="text-align: center; width: 10%"><input id="checkbox" type="checkbox" /></th>
                    #     <th style="width: 70%">文件名</th>
                    #     <th>操作</th>
                    #     </tr></thead>

                    #     <tbody id="files-container-<%= id %>">
                    #     </tbody>
                    # </table>
            else
                _.template '''
                    <div class="input-append c-picker">
                        <span class="uneditable-input">
                            <span id="percent-<%= id %>" class="label label-info"></span>
                            <span id="text-<%= id %>"><%= text %></span>
                        </span>
                        <span id="preview-span-<%= id %>"></span>
                        <span id="download-span-<%= id %>"></span>
                        <a id="trigger-<%= id %>" class="btn <%= triggerClass %>"><i class="icon-file-text"/></a>
                        <input type="file" style="display:none" id="hidden-input-<%= id %>"/>
                    </div>
                '''
                
        loadData: (data) ->
            super
            value = data[@name]
            value = if _.isString(value) then id: value else value
            @setValue value
            @setText value?.filename
            if @options.multiple and @value
                ctn = @container.find '#files-container-' + @id
                ctn.empty()
                @datas or= {}

                for item in @value or []
                    if isImage item.contentType 
                        isImageFile = true 
                    else 
                        isImageFile = false

                    ctn.append(row(id: item.id, name: item.filename, url: @options.url + '/' + item.id, isImageFile: isImageFile, preview: @options.preview))
                    @datas[item.id] = result: item, uploaded: true

                    ctn.find('div.progress > div').addClass('bar-success').css('width', '100%')
                    if @options.preview && item && item.id
                        popover = $('#popover-span-' + item.id)
                        @setPopoverData popover, @options.url + '/' + item.id, item.id

                        
            if value and value.id
                trigger = @container.find '#trigger-' + @id
                trigger.addClass('btn-danger')
                trigger.html('<i class="icon-remove"></i>')

                @downloadSingle @options, @id, value.id, @id, @options.url, value.contentType
                @previewSingle @options, @id, value.id, @id, @options.url, value.contentType

        renderSingle: (input) ->
            me = @
            percent = @container.find '#percent-' + @id
            trigger = @container.find '#trigger-' + @id
            options = _.extend {}, @options,
                fileInput: null
                add: (e, data) =>
                    @value = null
                    percent.removeClass('label-success').removeClass('label-important').addClass 'label-info'
                    name = data.files[0].name
                    @setText name
                    data.process ->
                        return input.fileupload 'process', data
                    .done (data) ->
                        data.submit().done (res) ->
                            me.downloadSingle options, data.id, res.id, @id, options.url, data.files[0].type
                            me.previewSingle options, data.id, res.id, @id, options.url, data.files[0].type
                    .fail (data) =>
                        if data.files.error
                            percent.removeClass('label-success').removeClass('label-info').addClass 'label-important'
                            percent.html '<i class="icon-remove"/>'
                            @setText data.files[0].error

                progress: (e, data) ->
                    percent.html (data.loaded / data.total).toFixed(2) * 100 + '%'
                done: (e, data) =>
                    percent.removeClass('label-info').removeClass('label-important').addClass 'label-success'
                    percent.html '<i class="icon-ok"/>'
                    @setValue data.result
                    trigger.addClass('btn-danger')
                    trigger.html('<i class="icon-remove"></i>')
                fail: (e, data) ->
                    percent.removeClass('label-info').removeClass('label-success').addClass 'label-important'
                    percent.html '<i class="icon-remove"/>'

            input.fileupload options
            input.change (e) ->
                input.fileupload 'add', files: e.target.files

        renderMultiple: (input) ->
            me = @
            options = _.extend {}, @options,
                fileInput: null
                add: (e, data) =>
                    d = _.extend {}, data,
                        id: _.uniqueId 'u-data-'
                    f = d.files[0]
                    @datas or= {}
                    @datas[d.id] = d
                    d.process ->
                        return input.fileupload 'process', data
                    .done (a,b,c)=>
                        tpl = row
                            id: d.id
                            name: f.name
                            type: f.type
                            size: calcSize f.size
                            isImageFile: isImage f.type
                            # url: 
                            preview: options.preview
                        $(tpl).appendTo @container.find('#files-container-' + @id)
                        d.submit().done (res) ->
                            if options.preview
                                popover = $('#popover-span-' + @id)
                                me.setPopoverData popover, @url + '/' + res.id, res.id
                            download = $('#download-' + @id)
                            me.setDownloadData download, @url + '/' + res.id

                    .fail (dd) =>
                        tpl = row
                            id: d.id
                            name: dd.files[0].error
                            type: f.type
                            size: calcSize f.size
                            preview: options.preview
                        $(tpl).appendTo @container.find('#files-container-' + @id)
                        bar = @container.find '#bar-' + d.id
                        bar.css 'width', '100%'
                        bar.removeClass('bar-success').addClass 'bar-danger'

                progress: (e, data) =>
                    bar = @container.find '#bar-' + data.id
                    return if bar.hasClass 'bar-danger'
                    bar.css('width', (data.loaded / data.total).toFixed(2) * 100 + '%')
                done: (e, data) =>
                    bar = @container.find '#bar-' + data.id
                    data.uploaded = true
                    bar.removeClass('bar-danger').addClass 'bar-success'
                    @datas[data.id] = data

                fail: (e, data) ->
                    bar = @container.find '#bar-' + data.id
                    bar.removeClass('bar-success').addClass 'bar-danger'
                    
            @container.delegate 'input[id="checkbox"]', 'click', (e) =>
                if $(e.target).attr('checked')
                    $(e.target).attr('checked', true);
                    $('tbody input[type="checkbox"]').attr('checked',true);
                else 
                    $(e.target).removeAttr('checked');
                    $('tbody input[type="checkbox"]').removeAttr('checked');

            @container.delegate 'a[id=^"remove"]', 'click', (e) =>
                $('tbody input[type="checkbox"]').each (e) ->
                    if $(this).attr('checked')
                        id = $(this).attr('id').match(/check-(.*)$/)[1]
                        delete _this.datas[id]
                        $(this).closest('tr').remove()


            if @options.preview
                @container.delegate 'a[id^="preview"]', 'click', (e) =>
                    id = $(e.target).attr('id').match(/preview-(.*)$/)[1]
                    popover = @container.find('#popover-span-' + id)
                    @popoverToggle popover, @options.url + '/' + id, id

            input.fileupload options
            input.change (e) ->
                input.fileupload 'add', files: e.target.files

            @getFormData = =>
                (v.result['id'] for k, v of @datas when v.uploaded is true)

        setPopoverData: (popover, url, id) ->
            popover.attr 'data-content', '<img id="preview-img-' + id + '" class="upload-preview" src="' + url + '" />'

        # 设置下载链接的地址
        setDownloadData: (download, url) ->
            download.attr 'href', url

        popoverToggle: (popover, url, id) ->
            me = @
            _next = popover.next()
            if _next.hasClass('popover') && _next.css('display') == 'block'
                _next.hide()
            else
                $('a[id^="popover-span"]').each (e) ->
                    if $(this).data('popover')
                        $(this).next().hide()
                popover.attr('data-content', popover.attr 'data-content')
                popover.popover html: true
                popover.popover 'show'
                $('#preview-img-' + id).click ->
                        me.popoverToggle popover, url, id
                        window.open url, id
        # 单附件预览
        previewSingle: (options, did, rid, $id, url, contentType) ->
            # 只有图片类型，才能预览
            return if isImage(contentType) is false
            if options.preview
                _url = url + '/' + rid
                _preview = """
                    <a id="popover-span-#{did}" class="btn btn-success upload-preview-btn" data-rel="popover" data-placement="#{options.preview}" style="margin-right:87px;" data-content="<img id='preview-img-#{rid}' class='upload-preview' src='#{_url}'' />"><i class="icon-eye-open"/></a>
                    <a id="preview-#{did}" class="btn btn-success" href="javascript: void 0"  style="margin-right:87px;"><i class="icon-eye-open"/></a>
                """
                $('#preview-span-' + did).html _preview

                @container.find('#preview-' + $id).click (e) =>
                    popover = @container.find('#popover-span-' + $id)
                    @popoverToggle popover, _url, rid

        # 单附件下载
        downloadSingle: (options, did, rid, $id, url, contentType) ->
            # 只有图片类型，才能预览
            _url = url + '/' + rid
            _download = """
                <a id="download-#{did}" class="btn btn-success" href="#{_url}"  style="margin-right:43px;"><i class="icon-download"/></a>
            """
            $('#download-span-' + did).html _download

        render: ->
            return if @renderred
            @renderred = true

            @container.html @getTemplate() @

            input = @container.find '#hidden-input-' + @id
            if @options.multiple is true
                @renderMultiple input
            else
                @renderSingle input

            @container.find('#trigger-' + @id).click (e) =>
                t = $(e.currentTarget)
                if isdanger = t.hasClass('btn-danger')
                    @value = id: ''
                    t.removeClass('btn-danger')
                    t.html '<i class="icon-file-text"></i>'
                    @container.find('#percent-' + @id).empty()
                    @container.find('#text-' + @id).empty()
                else
                    input.click()

                if @options.preview
                    if isdanger
                        $('#preview-' + @id).css 'margin-right': '-0.5px'
                        popover = $('#popover-span-' + @id)
                        popover.css 'margin-right': '-0.5px'
                        _next = popover.next()
                        _next.remove()
                
    cdeio.registerComponentHandler 'file-picker', (->), (el, options = {}, view) ->
        opt = _.extend {}, options,
            view: view
            container: el
            chooserType: (->)

        picker = new FilePicker opt
        picker.render()
        picker
