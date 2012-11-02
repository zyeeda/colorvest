define({
    extend: {
        templateHelpers: function() {
            var title = this.feature.startupOptions.title;
            return {
                title: title
            };
        }
    },
    
    avoidLoadingHandlers: true
});
