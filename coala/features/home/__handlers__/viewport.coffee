define
    showLauncher: (feature, view, component, obj) ->
        view.components[0].show()

    launchApp: (feature, view, component, obj) ->
        feature.module.getApplication().startFeature obj.featurePath, obj

    closeApp: (feature, view, targetFeature) ->
        feature.module.getApplication().stopFeature targetFeature
