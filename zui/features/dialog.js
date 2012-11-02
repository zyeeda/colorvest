
define(['underscore', 'jquery', 'libs/bootstrap/bootstrap'],function(_, $) {
    return {
        views: [{
            name: 'dialog-title', region: 'title' 
        }, {
            name: 'dialog-buttons', region: 'buttons'
        }],
        avoidLoadingModel: true,
        
        extend: {
            initRenderTarget: function(su) {
                var root = this.module.getApplication(), id =  _.uniqueId('dialog'), c, me = this;
                $('<div class="modal hide" id="'+ id + '"><div id="' + this.startupOptions.view.cid + '"></div>').appendTo(document.body);
                this.containerId = id;
                this.dialogContainer = c = $('#' + id);
                c.on('hide', function(event){
                    if (me.startedOptions.length > 1) {
                        event.preventDefault();
                    }
                    me.close();
                });
                if (this.startupOptions.view.options.dialogClass) {
                    c.addClass(this.startupOptions.view.options.dialogClass);
                }
                
                this.container =  $('#' + this.startupOptions.view.cid);
            },
            stop: function(su) {
                var root = this.module.getApplication();
                if (this.startupOptions.view.options.dialogClass) {
                    this.dialogContainer.removeClass(this.startupOptions.view.options.dialogClass);
                }
                su.apply(this);
            },
            start: function(su) {
                var promise, me = this, deferred = $.Deferred(),
                startedOptions = me.startedOptions || (me.startedOptions = []);
                startedOptions.push(me.startupOptions);
                this.deferredView.done(function(){
                    me.inRegionViews['body'] = me.startupOptions.view;
                    promise = su.call(me);

                    promise.done(function() {
                        me.modal = $('#' + me.containerId).modal();
                        deferred.resolve(me);
                    });
                });
                return deferred.promise();
            },
            show: function(su, options) {
                var view = $('#' + options.view.cid), currentView = this.startupOptions.view, deferred = $.Deferred();

                if (view.size() != 0) {
                    if (currentView.options.dialogClass) {
                        this.dialogContainer.removeClass(currentView.options.dialogClass);
                    }
                    if (options.view.options.dialogClass) {
                        this.dialogContainer.addClass(options.view.options.dialogClass);
                    }
                    this.startedOptions.push(options);
                    $('#' + currentView.cid).hide();
                    view.show();
                    deferred.resolve(this);
                    return deferred;
                } else {
                    this.dialogContainer.append('<div id="' + options.view.cid + '"></div>');
                    this.container = $('#' + options.view.cid);
                    this.initLayout();
                    if (currentView.options.dialogClass) {
                        this.dialogContainer.removeClass(currentView.options.dialogClass);
                    }
                    if (options.view.options.dialogClass) {
                        this.dialogContainer.addClass(options.view.options.dialogClass);
                    }
                    $('#' + currentView.cid).hide();
                    this.startupOptions = options;
                    return this.start();
                }
            },
            close: function() { // for close button
                var options, current, app;
                if (this.startedOptions.length > 1) {
                    options = this.startedOptions.pop();
                    current = this.startedOptions[this.startedOptions.length - 1];
                    if (options.view.options.dialogClass) {
                        this.dialogContainer.removeClass(options.view.options.dialogClass);
                    }
                    if (current.view.options.dialogClass) {
                        this.dialogContainer.addClass(current.view.options.dialogClass);
                    }
                    this.startupOptions = current;
                    $('#' + options.view.cid).hide();
                    $('#' + current.view.cid).show();
                } else {
                    app = this.module.getApplication();
                    app.stopFeature(this);
                    app.applicationRoot._modalDialog = null;
                    this.dialogContainer.remove();
                }
            }
        }
    };
});
