define
    launchApp: (feature, view, component, obj) ->
        app.startFeature obj.featurePath, obj

    closeFeature: (feature, view, targetFeature) ->
        app.stopFeature targetFeature
