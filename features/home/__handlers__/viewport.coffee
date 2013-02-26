define
    launchApp: (feature, view, component, obj) ->
        app.startFeature obj.path, obj

    closeFeature: (feature, view, targetFeature) ->
        app.stopFeature targetFeature

