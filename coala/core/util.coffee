
util =
    getBaseName : (base) ->
        str = []
        str.push "[#{base.baseName}]"
        if base.path
            str.push "[#{base.path()}]"
        else if base.module and base.feature
            str.push "[#{base.module.path(base.feature.baseName)}]"
        else if base.module
            str.push "[#{base.module.path()}]"
        str.join ' under '

    log : (base, messages...) ->
        return if not window.console
        messages.unshift util.getBaseName base
        console.log.apply console, messages

    error : (base, messages...) ->
        messages.unshift util.getBaseName base
        throw new Error(messages.join ' ')

define util
