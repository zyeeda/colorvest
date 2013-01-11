// Generated by CoffeeScript 1.4.0
(function() {

  define(['underscore', 'jquery', 'coala/coala', 'coala/vendors/jquery/ztree/jquery.ztree.all-3.3'], function(_, $, coala) {
    var addTreeData, dndEvents, editEvents, mouseEvents, normalEvents;
    addTreeData = function(tree, options, data, parent, obj) {
      var value, _i, _j, _len, _len1, _ref;
      if (parent == null) {
        parent = null;
      }
      if (_.isFunction((_ref = options.data.simpleData) != null ? _ref.pId : void 0)) {
        for (_i = 0, _len = data.length; _i < _len; _i++) {
          value = data[_i];
          value.pId = options.data.simpleData.pId(value);
        }
        delete options.data.simpleData.pId;
      }
      for (_j = 0, _len1 = data.length; _j < _len1; _j++) {
        value = data[_j];
        if (obj) {
          _.extend(value, obj);
        }
      }
      return tree.addNodes(parent, data, true);
    };
    normalEvents = ['beforeAsync', 'beforeCheck', 'beforeClick', 'beforeCollapse', 'beforeDblClick', 'beforeExpand', 'beforeRightClick', 'onAsyncError', 'onAsyncSuccess', 'onCheck', 'onClick', 'onCollapse', 'onDblClick', 'onExpand', 'onRightClick'];
    dndEvents = ['beforeDrag', 'beforeDragOpen', 'beforeDrop', 'onDrag', 'onDrop'];
    editEvents = ['beforeEditName', 'beforeRemove', 'beforeRename', 'onNodeCreated', 'onRemove', 'onRename'];
    mouseEvents = ['beforeMouseDown', 'beforeMouseUp', 'onMouseDown', 'onMouseUp'];
    return coala.registerComponentHandler('tree', (function() {}), function(el, opt, view) {
      var beforeExpand, callback, cb, cbEvents, name, obj, options, simpleData, tree, value, _i, _len;
      options = _.extend({}, opt);
      delete options.async;
      options.data || (options.data = {});
      simpleData = _.extend({}, options.data.simpleData);
      simpleData.enable = true;
      if (!simpleData.pId) {
        simpleData.pId = (function(dataRow) {
          var _ref;
          return (_ref = dataRow.parent) != null ? _ref.id : void 0;
        });
      }
      options.data.simpleData = simpleData;
      cbEvents = [].concat(normalEvents);
      if (options.enableDndEvents === true) {
        cbEvents = cbEvents.concat(dndEvents);
      }
      if (options.enableEditEvents === true) {
        cbEvents = cbEvents.concat(editEvents);
      }
      if (options.enableMouseEvents === true) {
        cbEvents = cbEvents.concat(mouseEvents);
      }
      callback = _.extend({}, options.callback || {});
      cb = {};
      obj = {};
      for (_i = 0, _len = cbEvents.length; _i < _len; _i++) {
        name = cbEvents[_i];
        cb[name] = view.feature.delegateComponentEvent(view, obj, 'tree:' + name, callback[name]);
        delete callback[name];
      }
      for (name in callback) {
        value = callback[name];
        cb[name] = view.bindEventHandler(value);
      }
      options.callback = cb;
      if (options.isAsync === true) {
        callback = options.callback || (options.callback = {});
        beforeExpand = function(treeId, d) {
          var id, idName, tree;
          if (d !== null && d['__inited'] === true) {
            return;
          }
          d && (d['__inited'] = true);
          tree = $.fn.zTree.getZTreeObj(treeId);
          idName = simpleData.idKey || 'id';
          id = d === null ? (options.parentValueOfRoot ? options.parentValueOfRoot : false) : d[idName];
          return $.when(view.collection.fetch({
            data: {
              parent: id
            }
          })).done(function() {
            return addTreeData(tree, options, view.collection.toJSON(), d, {
              isParent: true
            });
          });
        };
        callback.beforeExpand = beforeExpand;
        tree = $.fn.zTree.init(el, options, null);
        beforeExpand(tree.setting.treeId, null);
      } else {
        if (options.treeData) {
          $.fn.zTree.init(el, options, options.treeData);
        } else {
          tree = $.fn.zTree.init(el, options, []);
          $.when(view.collection.fetch()).done(function() {
            var data;
            data = view.collection.toJSON();
            return addTreeData(tree, options, data);
          });
        }
      }
      obj.component = tree;
      return tree;
    });
  });

}).call(this);
