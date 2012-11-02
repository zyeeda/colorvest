define(['jquery', 'zui/coala/loader-plugin-manager'], function($, LoaderManager){
    var getFormData = function(view) {
        var values = view.$$('form').serializeArray(),
            data = {};
        _(values).map(function(item){
            if (item.name in data) {
                if (_.isArray(data[item.name]))
                    data[item.name] =  data[item.name].concat([item.value]);
                else
                    data[item.name] = [data[item.name], item.value];
            } else {
                data[item.name] = item.value;
            }
            view.model.set(data);
            _(view.components).each(function(component){
                if (_.isFunction(component.getFormData)) {
                    var d = component.getFormData();
                    if (d) view.model.set(d.name, d.value);
                }
            });

        });
                      
    };

    return {
        audit: function() {
            var me = this,
                grid = me.feature.views['grid'].components[0],
                ogrid = me.feature.views['completed-grid'].components[0]
                selected = grid.getGridParam('selrow'),
                app = me.feature.module.getApplication().applicationRoot;
            if (!selected)
                return app.info('请选择要操作的记录');

            me.feature.model.set('id', selected);
            $.when(me.feature.model.fetch()).done(function(){
                LoaderManager.invoke('view', me.feature.module, me.feature, 'forms:' + selected).done(function(view){
                    app.showDialog({
                        view: view,
                        title: 'Task Process',
                        buttons: [{
                            label: 'Finish',
                            fn: function(){
                                getFormData(view);
                                var valid = view.$$('form').valid();
                                if (!valid) return false;
                                view.model.set('id', selected);
                                view.model.save().done(function(){
                                    grid.trigger('reloadGrid');
                                    ogrid.trigger('reloadGrid');
                                });
                                return true;
                            }
                        }, {
                            label: 'Reject',
                            fn: function() {
                                me.feature.request({
                                    url: 'reject/' + selected
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
