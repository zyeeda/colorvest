define(['zui/coala/view', 'underscore'], function(View, _) {

    return {
        showPicker: function() {
            var options = this.feature.startupOptions, gridOptions, 
            app = this.feature.module.getApplication(),
            root = app.applicationRoot;
            if (!this.dialogView) {
                gridOptions = _.extend(options.grid || {}, {
                    type: 'grid',
                    selector: 'grid'
                });
                this.dialogView = new View({
                    baseName: 'grid-picker-grid-view',
                    feature: this.feature,
                    module: this.module,
                    model: options.url,
                    components: [gridOptions],
                    avoidLoadingHandlers: true
                })
            }
            root.showDialog({
                title: options.title,
                view: this.dialogView,
                buttons: [{
                    label: 'OK',
                    fn: _.bind(function(me) {
                        var grid = me.dialogView.components[0],
                            selected = grid.getGridParam('selrow');
                        if (!selected) {
                            return false;
                        }
                        var rowData = grid.getRowData(selected),
                            text = (options.toText || function(data) {
                                return  data.name;
                            })(rowData);
                        me.$('text').val(text);
                        options.valueField.val(selected);
                        return true;
                    }, this, this)
                }]
            });
            
        }
    };
});
