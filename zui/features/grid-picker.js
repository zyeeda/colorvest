define({
    layout: 'one-region',

    views:[{name: 'grid-picker-field', region: 'main'}],
    
    avoidLoadingModel: true,
    
    extend: {
        initRenderTarget: function(){
            this.container = this.startupOptions.el;
        }
    }
});
