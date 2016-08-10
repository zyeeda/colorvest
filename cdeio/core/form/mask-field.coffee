define [
    'cdeio/core/form/form-field'
    'underscore'
    'cdeio/components/masked-input'
], (FormField, _) ->

    class MaskField extends FormField
        constructor: ->
            super
            @type = 'text'
            @pattern = @options.pattern || ''
        getComponents: ->
            return [] if @readOnly
            [_.extend {}, @options, type: 'mask', selector: @id]
        getTemplateString: -> '''
            <% if (readOnly) { %>
                <div class="c-view-form-field">
                    <% if (!hideLabel) { %>
                    <div class="field-label"><%= label %></div>
                    <% } %>
                    <div id="<%= id %>" class="field-value">{{<%= value %>}}</div>
                </div>
            <% } else { %>
                <div class="control-group">
                    <% if (!hideLabel) { %>
                    <label class="control-label" for="<%= id %>"><%= label %><% if (required) { %>
                        <span class="required-mark">*</span>
                    <% } %></label><% } %>
                  <div class="controls">
                    <input type="<%= type %>" class="input span12 mask" id="<%= id %>" name="<%= name %>" pattern="<%= pattern %>" value="{{<%= value %>}}" />
                  </div>
                </div>
            <% } %>
        '''

    FormField.add 'mask', MaskField

    MaskField
