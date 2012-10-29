define({
    events: {
        'click show-picker': 'showPicker',
        'click remove-item': 'removeItem'
    },
    
    components: [function() {
        var options = this.feature.startupOptions.grid || {};
        options.type = 'grid';
        options.selector = 'grid';
        return options
    }]
});
