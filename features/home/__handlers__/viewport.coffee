define
    launchApp: (feature, view, component, obj) ->
        feature.module.getApplication().startFeature obj.featurePath, obj

    closeFeature: (feature, view, targetFeature) ->
        feature.module.getApplication().stopFeature targetFeature
