require =
    paths:
        text: 'cdeio/vendors/require/plugins/text'

        jquery: 'cdeio/vendors/jquery/jquery'
        underscore: 'cdeio/vendors/lodash.underscore.min'
        backbone: 'cdeio/vendors/backbone'
        marionette: 'cdeio/vendors/backbone.marionette'
        handlebars: 'cdeio/vendors/handlebars-amd'
        bootstrap: 'cdeio/vendors/bootstrap/bootstrap'

        jqgrid: 'cdeio/vendors/jquery/jqgrid/jquery.jqGrid.src'

    shim:
        'cdeio/cdeio': ['jquery']
        bootstrap: ['jquery']
        jqgrid: ['cdeio/vendors/jquery/jqgrid/i18n/grid.locale-cn']

        'cdeio/vendors/ace': ['jquery', 'cdeio/vendors/ace-elements']
        'cdeio/vendors/ace-elements': ['jquery']

        'cdeio/vendors/jquery/layout/jquery.layout': ['cdeio/vendors/jquery/ui/draggable', 'cdeio/vendors/jquery/ui/effect-slide', 'cdeio/vendors/jquery/ui/effect-drop', 'cdeio/vendors/jquery/ui/effect-scale']
        'cdeio/vendors/jquery/layout/jquery.layout.resizeTabLayout': ['cdeio/vendors/jquery/layout/jquery.layout']

        'cdeio/vendors/jquery/ui/datepicker-zh-CN': ['cdeio/vendors/jquery/ui/datepicker']
        'cdeio/vendors/jquery/timepicker/jquery-ui-timepicker': ['cdeio/vendors/jquery/ui/datepicker']
        'cdeio/vendors/jquery/timepicker/jquery-ui-timepicker-zh-CN': ['cdeio/vendors/jquery/timepicker/jquery-ui-timepicker']

        'cdeio/vendors/jquery/validation/jquery.validate': ['jquery']
        'cdeio/vendors/jquery/validation/messages_zh': ['cdeio/vendors/jquery/validation/jquery.validate']

        'cdeio/vendors/jquery/flot/jquery.flot.min': ['jquery']
        'cdeio/vendors/jquery/flot/jquery.flot.pie.min': ['jquery', 'cdeio/vendors/jquery/flot/jquery.flot.min']
        'cdeio/vendors/jquery/flot/jquery.flot.resize.min': ['jquery', 'cdeio/vendors/jquery/flot/jquery.flot.min']
        'cdeio/vendors/jquery/flot/jquery.flot.axislabels': ['jquery', 'cdeio/vendors/jquery/flot/jquery.flot.min']

        'cdeio/vendors/jquery/dataTables/jquery.dataTables.bootstrap': ['jquery', 'cdeio/vendors/jquery/dataTables/jquery.dataTables']
        'cdeio/vendors/jquery/dataTables/ColReorderWithResize': ['jquery', 'cdeio/vendors/jquery/dataTables/jquery.dataTables.bootstrap']
        'cdeio/vendors/jquery/dataTables/FixedHeader': ['jquery', 'cdeio/vendors/jquery/dataTables/jquery.dataTables.bootstrap']
        'cdeio/vendors/jquery/dataTables/dataTables.treeTable': ['jquery', 'cdeio/vendors/jquery/dataTables/jquery.dataTables']
        'cdeio/vendors/jquery/dataTables/jquery.dataTables.columnFilter': ['jquery', 'cdeio/vendors/jquery/dataTables/jquery.dataTables']

        'cdeio/vendors/jquery/select2/select2': ['jquery']
        'cdeio/vendors/jquery/select2/select2_locale_zh-CN': ['jquery', 'cdeio/vendors/jquery/select2/select2']

        'cdeio/vendors/jquery/jquery.slimscroll.min': ['jquery']
        'cdeio/vendors/jquery/jquery.easy-pie-chart.min': ['jquery']
        'cdeio/vendors/jquery/jquery.colorbox': ['jquery']
        'cdeio/vendors/jquery/jquery.gritter': ['jquery']
        'cdeio/vendors/bootbox': ['jquery']
        'cdeio/vendors/jquery/jquery.tooltipster.min': ['jquery']
        'cdeio/vendors/jquery/datarangepicker/daterangepicker': ['jquery']

