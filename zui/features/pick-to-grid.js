define({
    layout: 'one-region',

    views:[{name: 'picker-field', region: 'main'}],

    extend: {
        initRenderTarget: function(){
            this.container = this.startupOptions.el;
        }
    },
    
    avoidLoadingModel: true
});
