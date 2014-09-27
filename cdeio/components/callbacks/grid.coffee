
define
    resizeToFit: ($grid, $parent) ->
        $parent = $grid.closest('.ui-jqgrid').parent() unless $parent?

        $bdiv = $grid.parents '.ui-jqgrid-bdiv'
        $header = $bdiv.prev()
        $pager = $bdiv.parent().siblings().last()

        $grid.jqGrid 'setGridHeight', $parent.height() - $header.height() - $pager.height() - 2

        # adjust width
        $grid.jqGrid 'setGridWidth', $parent.width() - 2

    onLayoutResize: (x, ui) ->
        me = this
        $ui = if ui.jquery then ui else $ ui.panel
        $ui.filter(':visible').find('.c-jqgrid-fit:visible').each ->
            $grid = $ @
            me.resizeToFit $grid, $ui
