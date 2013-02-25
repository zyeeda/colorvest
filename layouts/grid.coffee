define ['text!coala/layouts/templates/grid.html'], ->
    components: [
        type: 'layout'
        selector: 'gridLayout'
        defaults:
            spacing_open: 0
            hideTogglerOnSlide: true
            resizable: false
        north:
            togglerLength_open: 0
    ],
    regions:
        operators: 'operators-area'
        grid: 'grid-area'
