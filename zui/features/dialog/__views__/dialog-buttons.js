define(['underscore'], function(_) {
    return {

        extend: {
            templateHelpers: function() {
                var buttons = this.feature.startupOptions.buttons, i, id, e, el;
                this.eventHandlers || (this.eventHandlers = {});
                for (i = 0; i < buttons.length; i ++ ) {
                    id = _.uniqueId('button');
                    buttons[i].id = id;
                    e = this.wrapEvent('click ' + id, id);
                    this.events[e.name] = e.handler;
                    this.eventHandlers[id] = (function(fn){
                        var result = fn.apply(this);
                        if (result !== false) this.feature.modal.modal('hide');
                    }).bind(this, buttons[i].fn);
                }

                el = this.$el;
                this.$el = this.feature.dialogContainer;
                this.delegateEvents();
                this.$el = el;
                
                return {
                    buttons: this.feature.startupOptions.buttons
                };
            }
        }
    };
});
