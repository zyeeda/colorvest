
define({
    components: [{
        type: 'layout',
        defaults: {
            resizable: true
        },
        north: {
            spacing_open: 1,
            size: 60
        },
        south: {
            closable: false,
            resizable: false,
            spacing_open: 1,
            size: 60
        },
        west: {
            resizable: true,
            size: 250
        }
    },{
        type: 'tab',
        selector: '#center'
    }],
    
    regions: {
        north: '#north',
        south: '#south',
        west: '#west'
    }
        
});

