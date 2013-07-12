require =
    paths:
        text: 'coala/vendors/require/plugins/text'

        jquery: 'coala/vendors/jquery/jquery'
        jqueryui: 'coala/vendors/jquery/ui'
        underscore: 'coala/vendors/lodash'
        backbone: 'coala/vendors/backbone'
        marionette: 'coala/vendors/backbone.marionette'
        handlebars: 'coala/vendors/handlebars-amd'
        bootstrap: 'coala/vendors/bootstrap/bootstrap'

        jqgrid: 'coala/vendors/jquery/jqgrid/jquery.jqGrid.src'

    shim:
        'coala/coala': ['jquery']
        bootstrap: ['jquery']
        jqgrid: ['coala/vendors/jquery/jqgrid/i18n/grid.locale-cn']
        'coala/vendors/jquery/layout/jquery.layout': ['jqueryui/draggable', 'jqueryui/effect-slide', 'jqueryui/effect-drop', 'jqueryui/effect-scale']
        'coala/vendors/jquery/layout/jquery.layout.resizeTabLayout': ['coala/vendors/jquery/layout/jquery.layout']
        'coala/vendors/jquery/timepicker/jquery-ui-timepicker': ['jqueryui/datepicker']
        'coala/vendors/jquery/timepicker/jquery-ui-timepicker-zh-CN': ['coala/vendors/jquery/timepicker/jquery-ui-timepicker']
        'coala/vendors/jquery/validation/messages_zh': ['coala/vendors/jquery/validation/jquery.validate']
        'jqueryui/datepicker-zh-CN': ['jqueryui/datepicker']
        'coala/vendors/jquery/flot/jquery.flot.pie.min': ['jquery', 'coala/vendors/jquery/flot/jquery.flot.min']
        'coala/vendors/jquery/flot/jquery.flot.resize.min': ['jquery', 'coala/vendors/jquery/flot/jquery.flot.min']

        'coala/vendors/jquery/jquery.slimscroll.min': ['jquery']
        'coala/vendors/jquery/flot/jquery.flot.pie.min': ['jquery']
        'coala/vendors/jquery/jquery.easy-pie-chart.min': ['jquery']
        'coala/vendors/ace': ['jquery', 'coala/vendors/ace-elements']
        'coala/vendors/ace-elements': ['jquery']
        'coala/vendors/jquery/jquery.colorbox': ['jquery']
        'coala/vendors/jquery/dataTables/jquery.dataTables.bootstrap': ['jquery', 'coala/vendors/jquery/dataTables/jquery.dataTables']
