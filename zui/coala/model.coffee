define [
    'backbone'
], (Backbone) ->
    class Model extends Backbone.Model
        url: ->
            path = @path
            url = @view?.url() or @feature?.url() or ''
            url = if path then url + '/' + path else url
            if @isNew() then url else url + '/' + encodeURIComponent(@id)
    Model
