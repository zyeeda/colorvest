define(['zui/coala/view', 'underscore'], function(View, _) {

    return {
        showPicker: function() {
            var options = this.feature.startupOptions, gridOptions, 
            targetGrid = this.components[0];
            app = this.feature.module.getApplication(),
            root = app.applicationRoot;
            if (!this.dialogView) {
                gridOptions = _.extend(options.pickerGrid || {}, {
                    type: 'grid',
                    selector: 'grid'
                });
                this.dialogView = new View({
                    baseName: 'grid-picker-grid-view',
                    feature: this.feature,
                    module: this.module,
                    model: options.url,
                    components: [gridOptions]
                })
            }
            root.showDialog({
                title: options.title,
                view: this.dialogView,
                buttons: [{
                    label: 'OK',
                    fn: _.bind(function(me) {
                        var grid = me.dialogView.components[0],
                            selected = grid.getGridParam('selrow'), rowData;
                        if (!selected) {
                            return false;
                        }
                        rowData = grid.getRowData(selected);
                        exists = targetGrid.getRowData(selected);
                        if (_.include(targetGrid.getDataIDs(), rowData.id)) {
                            return false;
                        }
                        targetGrid.addRowData(rowData.id, rowData);
                        return true;
                    }, this, this)
                }]
            });
            
        },
        
        removeItem: function() {
            var options = this.feature.startupOptions, gridOptions, 
            targetGrid = this.components[0],
            selected = targetGrid.getGridParam('selrow');
            
            if (!selected) return;
            
            targetGrid.delRowData(selected);
        }
    };
});
