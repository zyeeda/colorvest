define [
    'backbone'
], (Backbone) ->

    class Collection extends Backbone.Collection
        url: ->
            @_url = new @model().url() if not @_url
            @_url
        parse: (data) ->
            @recordCount = data.recordCount
            @pageCount = data.pageCount
            @page = data.page
            data.results
    Collection
