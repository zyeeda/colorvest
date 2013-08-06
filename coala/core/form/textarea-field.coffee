define [
    'coala/core/form/form-field'
], (FormField) ->

    class TextareaField extends FormField
        constructor: ->
            super
            @type = 'textarea'

        getTemplateString: -> '''
            <% if (readOnly) { %>
                <div class="view-form-field">
                    <div class="field-label"><%= label %></div><div id="<%= id %>" class="field-value">{{<%= value %>}}</div>
                </div>
            <% } else { %>
                <div class="control-group">
                  <label class="control-label" for="<%= id %>"><%= label %></label>
                  <div class="controls">
                        <textarea class="input span12" id="<%= id %>" name="<%= name %>" rows="<%= rowspan %>">{{<%= value %>}}</textarea>
                  </div>
                </div>
            <%  } %>
            '''

    FormField.add 'textarea', TextareaField

    TextareaField
