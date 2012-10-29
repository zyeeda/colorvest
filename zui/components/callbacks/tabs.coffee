
define
    resizeFitTabPanel: (x, ui) ->
        $ui = if ui.jquery then ui else $ ui.panel
        $ui.filter(':visible').find('.ui-tabs-panel-fit:visible').each ->
            $this = $ @
            $parent = $this.parent()
            $this.innerHeight $parent.height()
