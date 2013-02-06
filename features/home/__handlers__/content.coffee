define
    launchApp: (feature, view, component, obj) ->
        app.startFeature obj.path, obj

    showLauncher: (feature, view) ->
        launcher = view.components[0]
        launcher.show()

    closeFeature: (feature, view, targetFeature) ->
        app.stopFeature targetFeature

