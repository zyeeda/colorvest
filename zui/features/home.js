
define({
    layout: 'main',

    views: [
        {name: 'header', region: 'north', avoidLoadingView: true, avoidLoadingHandlers: true},
        {name: 'footer', region: 'south', avoidLoadingView: true, avoidLoadingHandlers: true},
        {name: 'menu', region: 'west'}
    ],
    
    avoidLoadingModel: true
});
