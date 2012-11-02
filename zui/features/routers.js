define({
    routes: {
        'start/*path': 'hello'
    },

    hello: function(path) {
        this.module.getApplication().applicationRoot.startFeature(path);
    }
});
