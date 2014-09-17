define [
    'cdeio/core/form/form-field'
], (FormField) ->

    class TextareaField extends FormField
        constructor: ->
            super
            @type = 'textarea'

        getTemplateString: -> '''
            <% if (readOnly) { %>
                <div class="c-view-form-field">
                    <% if (!hideLabel) { %>
                    <div class="field-label"><%= label %></div>
                    <% } %> 
                    <div id="<%= id %>" class="field-value">{{<%= value %>}}</div>
                </div>
            <% } else { %>
                <% if (!hideLabel) { %>
                <div class="control-group">
                  <label class="control-label" for="<%= id %>"><%= label %><% if (required) { %>
                        <span class="required-mark">*</span>
                    <% } %></label><% } %>
                  <div class="controls">
                        <textarea class="input span12" id="<%= id %>" name="<%= name %>" style="height: <%= height %>px;">{{<%= value %>}}</textarea>
                  </div>
                </div>
            <%  } %>
            '''

    FormField.add 'textarea', TextareaField

    TextareaField
