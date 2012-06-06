require.config({
    paths: {
        CoffeeScript: 'libs/coffee-script',
        cs: 'libs/require/plugins/cs',
        i18n: 'libs/require/plugins/i18n',
        order: 'libs/require/plugins/order',
        text: 'libs/require/plugins/text',

        jquery: 'libs/jquery/jquery',
        jqueryui: 'libs/jquery/ui',
        underscore: 'libs/lodash',
        backbone: 'libs/backbone',
        marionette: 'libs/backbone.marionette',
        handlebars: 'libs/handlebars-amd'
    },
    waitSeconds: 0.2
});

define([
   'jquery',
   'cs!libs/zui/browser',
   'cs!app/application'
], function ($, detectBrowser, app) {

    $(function() {
        detectBrowser();
        app.start();
    });

});
