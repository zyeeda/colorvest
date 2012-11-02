define(['jquery', 'zui/coala/loader-plugin-manager'], function($, LoaderManager){

    return {
        viewIt: function() {
            var me = this,
                grid = me.feature.views['completed-grid'].components[0]
                gridView = me.feature.views['completed-grid'],
                selected = grid.getGridParam('selrow'),
                app = me.feature.module.getApplication();

            if (!selected)
                return app.info('请选择要操作的记录');

            gridView.model.set('id', selected);
            $.when(gridView.model.fetch()).done(function(){
                LoaderManager.invoke('view', me.feature.module, me.feature, 'forms:' + selected).done(function(view){
                    view.model = gridView.model;
                    app.showDialog({
                        view: view,
                        title: 'Task Process',
                        buttons: [{
                            label: 'Revoke',
                            fn: function() {
                                me.feature.request({
                                    url: 'revoke/' + selected
                                }).done(function(){
                                    grid.trigger('reloadGrid');
                                });
                            }
                        }]
                    });
                });
            });
            return true;
        }
    };
});
