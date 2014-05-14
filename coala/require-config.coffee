require =
    paths:
        text: 'coala/vendors/require/plugins/text'

        jquery: 'coala/vendors/jquery/jquery'
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

        'coala/vendors/ace': ['jquery', 'coala/vendors/ace-elements']
        'coala/vendors/ace-elements': ['jquery']

        'coala/vendors/jquery/layout/jquery.layout': ['coala/vendors/jquery/ui/draggable', 'coala/vendors/jquery/ui/effect-slide', 'coala/vendors/jquery/ui/effect-drop', 'coala/vendors/jquery/ui/effect-scale']
        'coala/vendors/jquery/layout/jquery.layout.resizeTabLayout': ['coala/vendors/jquery/layout/jquery.layout']

        'coala/vendors/jquery/ui/datepicker-zh-CN': ['coala/vendors/jquery/ui/datepicker']
        'coala/vendors/jquery/timepicker/jquery-ui-timepicker': ['coala/vendors/jquery/ui/datepicker']
        'coala/vendors/jquery/timepicker/jquery-ui-timepicker-zh-CN': ['coala/vendors/jquery/timepicker/jquery-ui-timepicker']

        'coala/vendors/jquery/validation/messages_zh': ['coala/vendors/jquery/validation/jquery.validate']

        'coala/vendors/jquery/flot/jquery.flot.min': ['jquery']
        'coala/vendors/jquery/flot/jquery.flot.pie.min': ['jquery', 'coala/vendors/jquery/flot/jquery.flot.min']
        'coala/vendors/jquery/flot/jquery.flot.resize.min': ['jquery', 'coala/vendors/jquery/flot/jquery.flot.min']

        'coala/vendors/jquery/dataTables/jquery.dataTables.bootstrap': ['jquery', 'coala/vendors/jquery/dataTables/jquery.dataTables']
        'coala/vendors/jquery/dataTables/ColReorderWithResize': ['jquery', 'coala/vendors/jquery/dataTables/jquery.dataTables.bootstrap']
        'coala/vendors/jquery/dataTables/FixedHeader': ['jquery', 'coala/vendors/jquery/dataTables/jquery.dataTables.bootstrap']
        'coala/vendors/jquery/dataTables/dataTables.treeTable': ['jquery', 'coala/vendors/jquery/dataTables/jquery.dataTables']
        'coala/vendors/jquery/dataTables/jquery.dataTables.columnFilter': ['jquery', 'coala/vendors/jquery/dataTables/jquery.dataTables']

        'coala/vendors/jquery/select2/select2': ['jquery']
        'coala/vendors/jquery/select2/select2_locale_zh-CN': ['jquery', 'coala/vendors/jquery/select2/select2']

        'coala/vendors/jquery/jquery.slimscroll.min': ['jquery']
        'coala/vendors/jquery/jquery.easy-pie-chart.min': ['jquery']
        'coala/vendors/jquery/jquery.colorbox': ['jquery']
        'coala/vendors/jquery/jquery.gritter': ['jquery']
        'coala/vendors/bootbox': ['jquery']

