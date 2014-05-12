
classToType = {}
for name in "Boolean Number String Function Array Date RegExp Undefined Null".split(" ")
    classToType["[object " + name + "]"] = name.toLowerCase()

classToType['[object JavaClass]'] = 'class'
classToType['[object JavaPackage]'] = 'package'

type = (obj) ->
    strType = Object::toString.call(obj)
    classToType[strType] or "object"

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
define util
