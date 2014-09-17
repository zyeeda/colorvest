define ->

    doFilter: ->
        form = @feature.views['form:filter']
        grid = @feature.views['grid:body'].components[0]
        @effectiveFilters = form.getFilters()
        grid.addFilters @effectiveFilters
        grid.refresh()

    doReset: ->
        form = @feature.views['form:filter']
        grid = @feature.views['grid:body'].components[0]
        grid.removeFilters @effectiveFilters
        delete @effectiveFilters
        form.reset()
        grid.refresh()
