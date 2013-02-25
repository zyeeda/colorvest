define [
    'coala/components/callbacks/grid'
    'text!coala/layouts/templates/grid.html'
], (cbGrid) ->
    components: [
        type: 'layout'
        selector: 'gridLayout'
        defaults:
            spacing_open: 0
            hideTogglerOnSlide: true
            resizable: false
        north:
            togglerLength_open: 0
        center:
            onresize: (paneName, paneElement) ->
                cbGrid.onLayoutResize(paneName, paneElement)
    ],
    regions:
        operators: 'operators-area'
        grid: 'grid-area'
