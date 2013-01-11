
define
    resizeToFit: ($grid) ->
        $parent = $grid.closest('.ui-jqgrid').parent()

        # adjust height
        marginTop = parseInt $parent.css 'margin-top'
        targetHeight = $parent.height() - marginTop

        $bdiv = $grid.parents '.ui-jqgrid-bdiv'
        $header = $bdiv.prev()

        $grid.jqGrid 'setGridHeight', targetHeight - $header.height() - 10

        # adjust width
        $grid.jqGrid 'setGridWidth', $parent.width()

    onLayoutResize: (x, ui) ->
        me = this
        $ui = if ui.jquery then ui else $ ui.panel
        $ui.filter(':visible').find('.ui-jqgrid-fit:visible').each ->
            $grid = $ @
            me.resizeToFit $grid, $ui
