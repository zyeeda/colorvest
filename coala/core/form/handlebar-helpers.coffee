define ['handlebars', 'underscore'], (H, _) ->
   
    classMakerup = ' class="input span12"'

    #Markup helpers
    openTag = (type, closing, attr) ->
        html = ["<#{type}"]
        for prop of attr
            html.push "#{prop}=\"#{attr[prop]}\"" if attr[prop]
        return html.join(' ') + classMakerup + '>' if closing
        html.join(' ') + classMakerup + '"/>'


    closeTag = (type) ->
        "<#{type}>"

    createElement = (type, closing, attr, contents) ->
        return openTag(type, closing, attr) + (contents || '') + closeTag type if closing
        openTag type, closing, attr


    extend = (obj1, obj2) ->
        for key of obj2
            obj1[key] = obj2[key]
        obj1

    # {{#form url class="form"}}{{/form}} 
    helperForm = (url, options) ->
        createElement('form', true, extend(
            action: url
            method: 'post'
        options.hash), options.fn @)

    # {{input "firstname" person.name}}
    helperInput = (name, type, options) ->
        new H.SafeString createElement('input', false, extend(
            name: name
            id: name
            type: type
        options.hash))

    # {{field "firstname"}}
    helperField = (name, options) ->
        groups = @['__view__'].options.fieldGroups
        for g of groups
            for f in groups[g]
                if _.isObject(f)
                    return helperInput f.name, f.type, options if f.name is name
                else
                    return helperInput f, 'text', options if f is name
        console.error "not found #{name} field info"


    H.registerHelper 'field', helperField
        
    H
