#define all scaffold dependents
define [
    'coala/core/loader-plugin-manager'

    # scaffolds
    'coala/scaffold/forms-view-loader'
    'coala/scaffold/notfound-feature-loader'
    'coala/scaffold/views-view-loader'
    'coala/scaffold/tree-views-view-loader'
    'coala/scaffold/treetable-views-view-loader'

    # all components
    'coala/components/layout'
    'coala/components/grid'
    'coala/components/accordion'
    'coala/components/tree'
    'coala/components/select'
    'coala/components/picker'
    'coala/components/tabs'
    'coala/components/datetimepicker'

    # features
    'coala/features/grid-picker.feature/feature'
    'coala/features/tree-picker.feature/feature'
    'coala/features/pick-to-grid.feature/feature'
    'coala/features/tasks.feature/feature'

    # layouts
    'coala/layouts/grid'
    'coala/layouts/one-region'

], (LoaderPluginManager, formsLoader, notFoundFeatureLoader, viewsLoader, treeViewsLoader, treeTableViewsLoader) ->

    LoaderPluginManager.register formsLoader
    LoaderPluginManager.register notFoundFeatureLoader
    LoaderPluginManager.register viewsLoader
    LoaderPluginManager.register treeViewsLoader
    LoaderPluginManager.register treeTableViewsLoader
