define({
    layout: 'one-region',

    views:[{name: 'picker-field', region: 'main'}],
    ignoreExists: true,
    
    extend: {
        initRenderTarget: function(){
            this.container = this.startupOptions.el;
        }
    },
    
    avoidLoadingModel: true
});
