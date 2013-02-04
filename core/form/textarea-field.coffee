define [
    'coala/core/form/form-field'
], (FormField) ->

    class TextareaField extends FormField
        constructor: ->
            super
            @type = 'textarea'

        getTemplateString: ->
            '''
                <div class="control-group">
                  <label class="control-label" for="<%= id %>"><%= label %></label>
                  <div class="controls">
                    <% if (readOnly) { %>
                        <span id="<%= id %>">{{<%= value %>}}</span>
                    <% } else { %>
                        <textarea class="input" id="<%= id %>" name="<%= name %>" rows="<%= rowspan %>">{{<%= value %>}}</textarea>
                    <%  } %>
                  </div>
                </div>
            '''

    FormField.add 'textarea', TextareaField

    TextareaField
