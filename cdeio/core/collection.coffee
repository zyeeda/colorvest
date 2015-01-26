define [
    'backbone'
], (Backbone) ->

    class Collection extends Backbone.Collection
        # 此接口应对外开发，以方便扩展
        url: ->
            if @feature.activeTab
                @_url = new @model().url()
            else
                @_url = new @model().url() if not @_url
            
            @_url
        parse: (data) ->
            @recordCount = data.recordCount
            @firstRecord = data.firstRecord
            data.results
    Collection
