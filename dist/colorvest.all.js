!function t(n,e,r){function o(u,p){if(!e[u]){if(!n[u]){var s="function"==typeof require&&require;if(!p&&s)return s(u,!0);if(i)return i(u,!0);throw new Error("Cannot find module '"+u+"'")}var a=e[u]={exports:{}};n[u][0].call(a.exports,function(t){var e=n[u][1][t];return o(e?e:t)},a,a.exports,t,n,e,r)}return e[u].exports}for(var i="function"==typeof require&&require,u=0;u<r.length;u++)o(r[u]);return o}({1:[function(t,n){var e,r,o,i={}.hasOwnProperty,u=function(t,n){function e(){this.constructor=t}for(var r in n)i.call(n,r)&&(t[r]=n[r]);return e.prototype=n.prototype,t.prototype=new e,t.__super__=n.prototype,t};r=t("react"),e=t("../core/app"),o=function(t){function n(){return n.__super__.constructor.apply(this,arguments)}return u(n,t),n.prototype.mapRegions=function(t){return r.createElement("div",{id:t.region,style:{height:t.height},className:"col-xs-12"},t.content)},n.prototype.render=function(){return r.createElement("div",{className:"container-fluid"},r.createElement("div",{className:"row"},this.options.regions.map(this.mapRegions)))},n}(e),n.exports=o},{"../core/app":3}],2:[function(t,n){var e,r,o;r=t("./app/stack"),o=t("./core/widget"),e={StackApp:r,Widget:o},e.utils={widgetHelper:t("./utils/widget-helper")},n.exports=e},{"./app/stack":1,"./core/widget":7,"./utils/widget-helper":8}],3:[function(t,n){var e,r,o,i={}.hasOwnProperty,u=function(t,n){function e(){this.constructor=t}for(var r in n)i.call(n,r)&&(t[r]=n[r]);return e.prototype=n.prototype,t.prototype=new e,t.__super__=n.prototype,t};o=t("react"),r=t("./base-widget"),e=function(t){function n(){return n.__super__.constructor.apply(this,arguments)}return u(n,t),n.prototype.start=function(){return o.render(this.render(),document.body)},n}(r),n.exports=e},{"./base-widget":4}],4:[function(t,n){var e,r,o;r=t("./layout"),o=t("./region"),e=function(){function t(t){this.options=t,this.name=t.name,this.initLayout(),this.initRegions()}return t.prototype.getLayout=function(){},t.prototype.getParent=function(){var t,n,e,r;for(r=this.layout.regions,n=0,e=r.length;e>n;n++)if(t=r[n],t.widget.name===this.name)return t},t.prototype.find=function(){},t.prototype.findRegion=function(t){var n,e,r,o;for(o=this.layout.regions,e=0,r=o.length;r>e;e++)if(n=o[e],n.widget.name===this.name)return n;return this.layout.regions[t]},t.prototype.findWidget=function(t){var n,e,r,o;for(o=this.layout.regions,e=0,r=o.length;r>e;e++)if(n=o[e],n.widget.name===t)return n.widget},t.prototype.initLayout=function(){return this.layout=new r({name:this.options.layout,parent:this}),this.layout},t.prototype.initRegions=function(){var t,n,e,r,i;for(this.layout.regions=[],r=this.options.regions,i=[],n=0,e=r.length;e>n;n++)t=r[n],i.push(this.layout.regions.push(new o({name:t.region,height:t.height,content:t.content,parent:this.layout})));return i},t}(),n.exports=e},{"./layout":5,"./region":6}],5:[function(t,n){var e;e=function(){function t(t){this.options=t,this.name=t.name,this.parent=t.parent}return t.prototype.getParent=function(){return this.parent},t.prototype.getRegions=function(){return this.regions},t}(),n.exports=e},{}],6:[function(t,n){var e;e=function(){function t(t){this.options=t,this.name=t.name,this.height=t.height,this.content=t.content,this.parent=t.parent}return t.prototype.getParent=function(){return this.parent},t.prototype.getWidget=function(){return this.widget},t.prototype.mountWidget=function(t){return this.widget=t},t.prototype.unmountWidget=function(){return this.widget=void 0},t}(),n.exports=e},{}],7:[function(t,n){var e,r,o={}.hasOwnProperty,i=function(t,n){function e(){this.constructor=t}for(var r in n)o.call(n,r)&&(t[r]=n[r]);return e.prototype=n.prototype,t.prototype=new e,t.__super__=n.prototype,t};e=t("./base-widget"),r=function(t){function n(){return n.__super__.constructor.apply(this,arguments)}return i(n,t),n.prototype.mountWidget=function(t,n){var e;return e=this.findRegion(n),e.mountWidget(t)},n.prototype.unmountWidget=function(){var t;return t=this.findRegion(regionName),t.unmountWidget()},n.prototype.activeRegion=function(){},n.prototype.render=function(){},n}(e),n.exports=r},{"./base-widget":4}],8:[function(t,n){var e,r=[].slice;e={joinClasses:function(){var t,n,e,o,i,u;for(t=arguments[0],o=2<=arguments.length?r.call(arguments,1):[],null==t&&(t=""),e=[],i=0,u=o.length;u>i;i++)n=o[i],e.push(n);return""!==t&&e.push(t),e}},n.exports=e},{}]},{},[2]);