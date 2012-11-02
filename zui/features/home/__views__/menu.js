
define(['jquery', 'underscore'], function($, _) {
    var handler = function(app, featureName, id, data) {
        app.startFeature(featureName, false, data);
        this.$$('li.active').removeClass('active');
        //this.$$('i.icon-white').removeClass('icon-white');

        this.$(id).parent().addClass('active');
        //this.$(id).children('i').addClass('icon-white');
    };

    return {
        model: 'system/menuitems',
        avoidLoadingHandlers: true,
        
        extend: {
            serializeData: function() {
                var deferred = $.Deferred(), me = this, app = me.feature.module.getApplication().applicationRoot;
                $.when(this.collection.fetch()).done(function(){
                    me.collection.each(function(data, i){
                        var id = data.get('id'), featureName = data.get('featurePath'), e;
                        me.eventHandlers[id] = _.bind(handler, me, app, featureName, id, data.toJSON());
                        e = me.wrapEvent('click ' + id, id);
                        me.events[e.name] = e.handler;
                    });
                    me.delegateEvents();

                    deferred.resolve({data:me.collection.toJSON()});
                });
                return deferred;
            }
        }
    };
});
