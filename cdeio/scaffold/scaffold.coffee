#define all scaffold dependents
define [
    'cdeio/core/loader-plugin-manager'

    # scaffold
    'cdeio/scaffold/scaffold-feature-loader'
    'cdeio/scaffold/form-view-loader'
    'cdeio/scaffold/grid-view-loader'
    'cdeio/scaffold/tree-view-loader'
    'cdeio/scaffold/treetable-view-loader'
    'cdeio/scaffold/process-view-loader'
    'cdeio/scaffold/process-form-view-loader'

    # all components
    'cdeio/components/layout'
    'cdeio/components/grid'
    'cdeio/components/accordion'
    'cdeio/components/tree'
    'cdeio/components/select'
    'cdeio/components/picker'
    'cdeio/components/tabs'
    'cdeio/components/datetimepicker'

    # features
    'cdeio/features/tasks.feature/feature'
    'cdeio/features/task-grid.feature/feature'

    # layouts
    'cdeio/layouts/grid'
    'cdeio/layouts/one-region'

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
