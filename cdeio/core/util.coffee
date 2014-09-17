
classToType = {}
for name in "Boolean Number String Function Array Date RegExp Undefined Null".split(" ")
    classToType["[object " + name + "]"] = name.toLowerCase()

classToType['[object JavaClass]'] = 'class'
classToType['[object JavaPackage]'] = 'package'

type = (obj) ->
    strType = Object::toString.call(obj)
    classToType[strType] or "object"

changeDropdownSource = (el, data, textKey) ->
    textKey = 'name' unless textKey
    el.select2
        width: '100%'
        query: (q) ->
            t = q.term
            result = []
            for d in data
                text = if d.text then d.text else d[textKey]
                if text.indexOf(t) >= 0
                    result.push id: d.id, text: text
            q.callback(results: result)

        initSelection: (e, fn) ->
            val = $(e).val()
            results = data
            _(results).each (item) ->
                fn(item) if String(item.id) == String(val) 

util =
    getBaseName: (base) ->
        str = []
        str.push "[#{base.baseName}]"
        if base.path
            str.push "[#{base.path()}]"
        else if base.module and base.feature
            str.push "[#{base.module.path(base.feature.baseName)}]"
        else if base.module
            str.push "[#{base.module.path()}]"
        str.join ' under '

    log: (base, messages...) ->
        return if not window.console
        messages.unshift util.getBaseName base
        console.log.apply console, messages

    error: (base, messages...) ->
        messages.unshift util.getBaseName base
        throw new Error(messages.join ' ')

    join: (paths..., cleanStartAndEndSlash) ->
        if type(cleanStartAndEndSlash) is 'string'
            paths.push cleanStartAndEndSlash
            cleanStartAndEndSlash = false

        result = ''
        result += '/' + p for p in paths
        result = result.substring 1
        result = result.replace /(\/){2,3}/g, '/'
        result = result.replace /(^\/)|(\/$)/g, '' if cleanStartAndEndSlash
        result

    changeDropdownData: (el, data, textKey) -> 
        if data instanceof Array
            changeDropdownSource(el, data, textKey)
        else
            $.ajax(data, dataType: 'json').done (d) =>
                changeDropdownSource el, d.results, textKey

    changePickerData: (view, data) ->
        url = ''
        if data instanceof Object
            for p of data
                url += '&' + p + '=' + data[p]
        else
            url = data
        view.options.dynamic = url
        true

define util
