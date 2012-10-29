define(['zui/coala/view', 'underscore'], function(View, _) {

    return {
        showPicker: function() {

            var options = this.feature.startupOptions, me = this,
                treeOptions = _.extend(options.tree || {}, {
                    type: 'tree',
                    selector: 'tree',
                    check: {
                        enable: true,
                        chkStyle: 'radio',
                        radioType: 'all'
                    },
                    data: {
                        simpleData: {
                            enable: true
                        }
                    }
                }),
                view = new View({
                    baseName: 'tree-picker-tree-view',
                    feature: this.feature,
                    module: this.module,
                    model: options.url,
                    components: [treeOptions]
                }),
                app = this.feature.module.getApplication()
                root = app.applicationRoot;

            root.showDialog({
                title: options.title,
                view: view,
                buttons: [{
                    label: 'OK',
                    fn: function() {
                        var tree = view.components[0],
                            selected = tree.getCheckedNodes();
                        if (selected.length == 0) {
                            return false;
                        }
                        var rowData = selected[0],
                            text = (options.toText || function(data) {
                                return  data.name;
                            })(rowData);
                        me.$('text').val(text);
                        options.valueField.val(rowData['id']);
                        return true;
                    }
                }]
            });
            
        }
    };
});
