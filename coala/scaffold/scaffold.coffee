#define all scaffold dependents
define [
    'coala/core/loader-plugin-manager'

    # scaffold
    'coala/scaffold/scaffold-feature-loader'
    'coala/scaffold/form-view-loader'
    'coala/scaffold/grid-view-loader'
    'coala/scaffold/tree-view-loader'
    'coala/scaffold/treetable-view-loader'

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
    'coala/features/tasks.feature/feature'
    'coala/features/task-grid.feature/feature'

    # layouts
    'coala/layouts/grid'
    'coala/layouts/one-region'

], (LoaderPluginManager, scaffoldFeatureLoader, formViewLoader, gridViewLoader, treeViewLoader, treeTableViewLoader) ->

    LoaderPluginManager.register scaffoldFeatureLoader
    LoaderPluginManager.register formViewLoader
    LoaderPluginManager.register gridViewLoader
    LoaderPluginManager.register treeViewLoader
    LoaderPluginManager.register treeTableViewLoader
