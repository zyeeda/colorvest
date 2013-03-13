({
    baseUrl: '../',
    out: 'coala/coala.js',
    optimize: 'none',
    preserveLicenseComments: false,
    paths: {
        text: 'coala/vendors/require/plugins/text',
        jquery: 'coala/vendors/jquery/jquery',
        jqueryui: 'coala/vendors/jquery/ui',
        underscore: 'coala/vendors/lodash',
        backbone: 'coala/vendors/backbone',
        marionette: 'coala/vendors/backbone.marionette',
        handlebars: 'coala/vendors/handlebars-amd',
        bootstrap: 'coala/vendors/bootstrap/bootstrap',
        jqgrid: 'coala/vendors/jquery/jqgrid/jquery.jqGrid.src'
    },
    shim: {
        'coala/coala': ['jquery'],
        bootstrap: ['jquery'],
        jqgrid: ['coala/vendors/jquery/jqgrid/i18n/grid.locale-cn'],
        'coala/vendors/jquery/layout/jquery.layout': ['jqueryui/draggable', 'jqueryui/effect-slide', 'jqueryui/effect-drop', 'jqueryui/effect-scale'],
        'coala/vendors/jquery/layout/jquery.layout.resizeTabLayout': ['coala/vendors/jquery/layout/jquery.layout'],
        'coala/vendors/jquery/timepicker/jquery-ui-timepicker': ['jqueryui/datepicker'],
        'coala/vendors/jquery/timepicker/jquery-ui-timepicker-zh-CN': ['coala/vendors/jquery/timepicker/jquery-ui-timepicker'],
        'coala/vendors/jquery/validation/messages_zh': ['coala/vendors/jquery/validation/jquery.validate'],
        'jqueryui/datepicker-zh-CN': ['jqueryui/datepicker']
    }
})
