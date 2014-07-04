#define all scaffold dependents
define [
    'coala/core/loader-plugin-manager'

    # scaffold
    'coala/scaffold/scaffold-feature-loader'
    'coala/scaffold/form-view-loader'
    'coala/scaffold/grid-view-loader'
    'coala/scaffold/tree-view-loader'
    'coala/scaffold/treetable-view-loader'
    'coala/scaffold/process-view-loader'
    'coala/scaffold/process-form-view-loader'

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

], (LoaderPluginManager, scaffoldFeatureLoader, formViewLoader, gridViewLoader, treeViewLoader, treeTableViewLoader, processViewLoader, processFormViewLoader) ->
    # 注册相应的 scaffold 加载器，新的 scaffold 需要在这里添加
    LoaderPluginManager.register scaffoldFeatureLoader
    LoaderPluginManager.register formViewLoader
    LoaderPluginManager.register gridViewLoader
    LoaderPluginManager.register treeViewLoader
    LoaderPluginManager.register treeTableViewLoader
    # 流程 view 记载器
    LoaderPluginManager.register processViewLoader
    LoaderPluginManager.register processFormViewLoader
