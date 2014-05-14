define [
    'underscore'
    'jquery'
    'coala/coala'
    'coala/components/picker-base'
    'handlebars'
    'coala/vendors/jquery/fileupload/jquery.iframe-transport'
    'coala/vendors/jquery/fileupload/jquery.fileupload'
    'coala/vendors/jquery/fileupload/jquery.fileupload-process'
    'coala/vendors/jquery/fileupload/jquery.fileupload-validate'
], (_, $, coala, Picker, H) ->

    units = ['B', 'Kb', 'Mb', 'Gb', 'Tb']
    calcSize = (size) ->
        i = 0
        while size > 1024
            size = size / 1024
            i++
        size.toFixed(2) + ' ' + units[i]

    row = H.compile '''<tr>
        <td><div class="progress" style="margin-bottom: 0px">
            <div class="bar" id="bar-{{id}}" style="width:1%; color: black;text-align:left;">&nbsp;&nbsp;{{name}}</div>
        </div></td>
        <td><a id="remove-{{id}}" href="javascript: void 0">删除</a></td>
    </tr>'''

    class FilePicker extends Picker.Picker
        getTemplate: ->
            if @options.multiple is true
                _.template ''' <div>
                    <a id="trigger-<%= id %>" class="btn <%= triggerClass %>"><i class="icon-search"/></a>
                    <input type="file" style="display:none" multiple="true" id="hidden-input-<%= id %>"/>
                    <table class="table table-bordered">
                        <thead><tr><th>文件名</th><th width="70"></th></tr></thead>
                        <tbody id="files-container-<%= id %>">
                        </tbody>
                    </table>
                </div>'''
            else
                _.template '''
                    <div class="input-append c-picker">
                        <span class="uneditable-input">
                            <span id="percent-<%= id %>" class="label label-info"></span>
                            <span id="text-<%= id %>"><%= text %></span>
                        </span>
                        <a id="trigger-<%= id %>" class="btn <%= triggerClass %>"><i class="icon-search"/></a>
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
                    ctn.append(row(id: item.id, name: item.filename))
                    @datas[item.id] = result: item, uploaded: true
                ctn.find('div.progress > div').addClass('bar-success').css('width', '100%')
            if value and value.id
                trigger = @container.find '#trigger-' + @id
                trigger.addClass('btn-danger')
                trigger.html('<i class="icon-remove"></i>')


        renderSingle: (input) ->
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
                        data.submit()
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
                    .done =>
                        tpl = row
                            id: d.id
                            name: f.name
                            type: f.type
                            size: calcSize f.size
                        $(tpl).appendTo @container.find('#files-container-' + @id)
                        d.submit()
                    .fail (dd) =>
                        tpl = row
                            id: d.id
                            name: dd.files[0].error
                            type: f.type
                            size: calcSize f.size
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

            @container.delegate 'a[id^="remove"]', 'click', (e) =>
                id = $(e.target).attr('id').match(/remove-(.*)$/)[1]
                delete @datas[id]
                $(e.target).closest('tr').remove()


            input.fileupload options
            input.change (e) ->
                input.fileupload 'add', files: e.target.files

            @getFormData = =>
                (v.result['id'] for k, v of @datas when v.uploaded is true)


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
                if t.hasClass('btn-danger')
                    @value = id: ''
                    t.removeClass('btn-danger')
                    t.html '<i class="icon-search"></i>'
                    @container.find('#percent-' + @id).empty()
                    @container.find('#text-' + @id).empty()
                else
                    input.click()

    coala.registerComponentHandler 'file-picker', (->), (el, options = {}, view) ->
        opt = _.extend {}, options,
            view: view
            container: el
            chooserType: (->)

        picker = new FilePicker opt
        picker.render()
        picker
