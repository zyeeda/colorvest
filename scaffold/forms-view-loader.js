// Generated by CoffeeScript 1.4.0
(function() {

  define(['coala/core/view', 'handlebars', 'underscore', 'jquery'], function(View, Handlebars, _, $) {
    var findFieldsInGroup, generateField, generateFields, generateForm, generateGroup, generators, getFormData, templates;
    getFormData = function(view) {
      var data, values;
      values = view.$$('form').serializeArray();
      data = {};
      _(values).map(function(item) {
        if (item.name in data) {
          return data[item.name] = _.isArray(data[item.name]) ? data[item.name].concat([item.value]) : [data[item.name], item.value];
        } else {
          return data[item.name] = item.value;
        }
      });
      view.model.set(data);
      return _(view.components).each(function(component) {
        var d;
        if (_.isFunction(component.getFormData)) {
          d = component.getFormData();
          if (d) {
            return view.model.set(d.name, d.value);
          }
        }
      });
    };
    templates = {
      unknown: _.template('<div class="control-group">\n  <label class="control-label" for="<%= id %>"><%= label %></label>\n  <div class="controls">\n    <% if (readOnly) { %>\n        <span>{{<%= value %>}}</span>\n    <% } else { %>\n        <input type="<%= type %>" class="input" id="<%= id %>" name="<%= name %>" value="{{<%= value %>}}" />\n    <% } %>\n  </div>\n</div>'),
      hidden: _.template('<input type="hidden" name="<%= name %>" value="{{<%= value %>}}"/>'),
      string: _.template('<div class="control-group">\n  <label class="control-label" for="<%= id %>"><%= label %></label>\n  <div class="controls">\n    <% if (readOnly) { %>\n        <span>{{<%= value %>}}</span>\n    <% } else { %>\n        <input type="text" class="input" id="<%= id %>" name="<%= name %>" value="{{<%= value %>}}"/>\n    <% } %>\n  </div>\n</div>'),
      'long-string': _.template('<div class="control-group">\n  <label class="control-label" for="<%= id %>"><%= label %></label>\n  <div class="controls">\n    <% if (readOnly) { %>\n        <span>{{<%= value %>}}</span>\n    <% } else { %>\n        <textarea class="input" id="<%= id %>" name="<%= name %>" rows="<%= rowspan %>">{{<%= value %>}}</textarea>\n    <%  } %>\n  </div>\n</div>'),
      group: _.template('<fieldset>\n    <% if (label) { %>\n    <legend><%= label %></legend>\n    <% } %>\n    <%= groupContent %>\n</fieldset>'),
      staticPicker: _.template('<div class="control-group">\n  <label class="control-label" for="<%= id %>"><%= label %></label>\n  <div class="controls">\n    <% if (readOnly) {%>\n        <span id="<%= id %>"/>\n    <% } else { %>\n        <input type="hidden" id="<%= id %>" name="<%= name %>" value="{{appearFalse <%= value %>}}"/>\n    <% } %>\n  </div>\n</div>'),
      gridPicker: _.template('<div class="control-group">\n  <label class="control-label" for="<%= id %>"><%= label %></label>\n  <div class="controls">\n    <input type="hidden" id="<%= id %>" name="<%= name %>" value="{{appearFalse <%= value %>}}"/>\n    <div id="grid-<%= id %>"></div>\n  </div>\n</div>'),
      form: _.template('<form class="form-horizontal">\n    <%= content %>\n    <%= hiddens %>\n    <input type="hidden" name="__formName__" value="<%= formName %>"/>\n</form>'),
      tabLayout: _.template('<%= pinedGroups %>\n<div>\n    <ul class="nav nav-tabs">\n        <%= lis %>\n    </ul>\n    <div class="tab-content">\n        <%= content %>\n    </div>\n</div>'),
      tabLi: _.template('<li <% if (i == 0) {%>class="active" <%}%>><a data-target="<%= id %>" data-toggle="tab"><%= title %></a></li>'),
      tabContent: _.template('<div class="tab-pane <%if (i == 0) {%>active<%}%>" id="<%= id %>">\n    <%= content %>\n</div>'),
      twoColumnsRow: _.template('<div class="row-fluid">\n    <div class="span6">\n        <%= field1 %>\n    </div>\n    <div class="span6">\n        <%= field2 %>\n    </div>\n</div>'),
      oneColumnRow: _.template('<div class="row-fluid">\n    <div class="span12">\n        <%= field1 %>\n    </div>\n</div>'),
      twoColumnsForm: _.template('<form class="form-horizontal container-fluid">\n    <%= content %>\n    <%= hiddens %>\n</form>'),
      manyPicker: _.template('<div class="control-group">\n  <label class="control-label" for="<%= id %>"><%= label %></label>\n  <div class="controls">\n    <div id="grid-<%= id %>"></div>\n  </div>\n</div>'),
      featureField: _.template('<div id="<%= id %>"></div>')
    };
    generateForm = function(options, components, viewName, features, events) {
      var columns, field, formContent, group, groupName, groupStrings, hiddens, i, id, others, tab, tabContentStrings, tabLiStrings, unusedGroupStrings, unusedGroups, _i, _j, _k, _l, _len, _len1, _len2, _len3, _ref, _ref1, _ref2, _ref3;
      if (options == null) {
        options = {};
      }
      hiddens = [];
      others = [];
      _ref = options.fields || [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        field = _ref[_i];
        (field.type === 'hidden' ? hiddens : others).push(field);
      }
      columns = 1;
      unusedGroups = (function() {
        var _ref1, _results;
        _ref1 = options.groups;
        _results = [];
        for (groupName in _ref1) {
          group = _ref1[groupName];
          if (group.columns > 1) {
            group.columns = columns = 2;
          }
          _results.push(groupName);
        }
        return _results;
      })();
      formContent = '';
      if (options.tabs) {
        tabLiStrings = [];
        tabContentStrings = [];
        unusedGroupStrings = [];
        _ref1 = options.tabs;
        for (i = _j = 0, _len1 = _ref1.length; _j < _len1; i = ++_j) {
          tab = _ref1[i];
          groupStrings = [];
          _ref2 = tab.groups;
          for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
            groupName = _ref2[_k];
            generateGroup(others, groupName, options.groups[groupName], components, groupStrings, features, events);
            unusedGroups = _.without(unusedGroups, groupName);
          }
          id = _.uniqueId('tab');
          tabLiStrings.push(templates.tabLi({
            i: i,
            id: id,
            title: tab.title
          }));
          tabContentStrings.push(templates.tabContent({
            i: i,
            id: id,
            content: groupStrings.join('')
          }));
        }
        for (_l = 0, _len3 = unusedGroups.length; _l < _len3; _l++) {
          groupName = unusedGroups[_l];
          generateGroup(others, groupName, options.groups[groupName], components, unusedGroupStrings, features, events);
        }
        formContent = templates.tabLayout({
          lis: tabLiStrings.join(''),
          content: tabContentStrings.join(''),
          pinedGroups: unusedGroupStrings.join('')
        });
      } else {
        groupStrings = [];
        _ref3 = options.groups;
        for (groupName in _ref3) {
          group = _ref3[groupName];
          generateGroup(others, groupName, group, components, groupStrings, features, events);
        }
        formContent = groupStrings.join('');
      }
      return {
        columns: columns,
        form: templates.form({
          content: formContent,
          hiddens: generateFields(hiddens, 1),
          formName: viewName
        })
      };
    };
    generateGroup = function(allFields, groupName, group, components, groupStrings, features, events) {
      var fields;
      fields = findFieldsInGroup(groupName, allFields);
      if (fields.length === 0) {
        return;
      }
      return groupStrings.push(templates.group({
        label: group.label,
        groupContent: generateFields(fields, group.columns, components, features, events)
      }));
    };
    generateFields = function(fields, columns, components, features, events) {
      var field, fieldStrings, items, row, template, _i, _j, _len, _len1;
      fieldStrings = [];
      row = [];
      if (columns === 2) {
        items = 0;
        for (_i = 0, _len = fields.length; _i < _len; _i++) {
          field = fields[_i];
          generateField(field, components, row, features, events);
          if (field.colspan === 2) {
            row.push(true);
          }
          if (row.length > 2) {
            throw new Error("the second column's colspan can not be 2");
          }
          if (row.length === 2) {
            template = row[1] === true ? templates.oneColumnRow : templates.twoColumnsRow;
            fieldStrings.push(template({
              field1: row.shift(),
              field2: row.shift()
            }));
          }
        }
        if (row.length !== 0) {
          fieldStrings.push(templates.oneColumnRow({
            field1: row.shift()
          }));
        }
      } else {
        for (_j = 0, _len1 = fields.length; _j < _len1; _j++) {
          field = fields[_j];
          generateField(field, components, fieldStrings, features, events);
        }
      }
      return fieldStrings.join('');
    };
    generators = {
      picker: function(field, components, fieldStrings, features) {
        if (!_.isString(field.pickerSource)) {
          fieldStrings.push(templates['staticPicker'](field));
          return components.push({
            type: 'select',
            selector: field.id,
            data: field.pickerSource,
            fieldName: field.name,
            readOnly: field.readOnly,
            initSelection: function(el, fn) {
              var val;
              val = $(el).val();
              if (!val) {
                return fn(field.pickerSource[0]);
              }
              if (!val) {
                return;
              }
              return _(field.pickerSource).each(function(item) {
                if (String(item.id) === String(val)) {
                  return fn(item);
                }
              });
            }
          });
        } else {
          fieldStrings.push(templates['gridPicker'](field));
          return components.push({
            type: 'grid-picker',
            selector: 'grid-' + field.id,
            url: field.pickerSource,
            title: '选择' + field.label,
            fieldName: field.name,
            readOnly: field.readOnlly,
            valueField: field.id,
            remoteDefined: true,
            statusChanger: field.statusChanger
          });
        }
      },
      date: function(field, components, fieldStrings, features, events) {
        fieldStrings.push(templates['string'](field));
        if (field.statusChanger === true) {
          events['change ' + field.id] = 'formStatusChanged';
        }
        if (!field.readOnly) {
          return components.push({
            type: 'datepicker',
            selector: field.id
          });
        }
      },
      'many-picker': function(field, components, fieldStrings, features) {
        fieldStrings.push(templates['gridPicker'](field));
        return components.push({
          type: 'many-picker',
          selector: 'grid-' + field.id,
          url: field.pickerSource,
          title: '选择' + field.label,
          remoteDefined: true,
          fieldName: field.name,
          readOnly: field.readOnly,
          grid: {
            datatype: 'local',
            colModel: field.colModel
          }
        });
      },
      feature: function(field, components, fieldStrings, features) {
        fieldStrings.push(templates['featureField'](field));
        return features.push({
          id: field.id,
          path: field.path,
          options: field.options
        });
      }
    };
    generateField = function(field, components, fieldStrings, features, events) {
      field.id = _.uniqueId(field.name);
      if (!field.value) {
        field.value = field.name;
      }
      field.readOnly = !!field.readOnly;
      if (field.statusChanger === true) {
        events['change ' + field.id] = 'innerFormStatusChanged';
      }
      if (_.isFunction(generators[field.type])) {
        return generators[field.type](field, components, fieldStrings, features, events);
      } else if (templates[field.type]) {
        return fieldStrings.push(templates[field.type](field));
      } else {
        return fieldStrings.push(templates.unknown(field));
      }
    };
    findFieldsInGroup = function(name, fields) {
      var field, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = fields.length; _i < _len; _i++) {
        field = fields[_i];
        if (field.group === name) {
          _results.push(field);
        }
      }
      return _results;
    };
    return {
      type: 'view',
      name: 'forms',
      fn: function(module, feature, viewName, args) {
        var deferred;
        deferred = $.Deferred();
        feature.request({
          url: 'configuration/forms/' + viewName,
          success: function(data) {
            var columns, components, events, features, form, view, _ref;
            components = [];
            features = [];
            events = {};
            _ref = generateForm(data, components, viewName, features, events), columns = _ref.columns, form = _ref.form;
            view = new View({
              baseName: viewName,
              module: module,
              feature: feature,
              components: components,
              avoidLoadingHandlers: true,
              dialogClass: columns === 2 ? 'two-column-dialog' : 'one-column-dialog',
              entityLabel: data.entityLabel,
              events: events,
              extend: {
                renderHtml: function(su, data) {
                  var template;
                  template = Handlebars.compile(form || '');
                  return template(data);
                },
                afterRender: function() {
                  var app, container, featureConfig, opts, p, promises, _i, _len,
                    _this = this;
                  app = this.feature.module.getApplication();
                  deferred = $.Deferred();
                  promises = [];
                  for (_i = 0, _len = features.length; _i < _len; _i++) {
                    featureConfig = features[_i];
                    container = this.$(featureConfig.id);
                    opts = _.extend({}, featureConfig.options);
                    opts.container = container;
                    opts.ignoreExists = true;
                    p = app.startFeature(featureConfig.path, opts);
                    p.done(function(feature) {
                      return feature.formView = _this;
                    });
                    promises.push(p);
                  }
                  $.when.apply($, promises).then(function() {
                    return deferred.resolve();
                  });
                  return deferred;
                }
              }
            });
            view.fillFormDataToModel = _.bind(getFormData, null, view);
            view.eventHandlers.innerFormStatusChanged = function(e) {
              var fcs, fsc, scaffold, _ref1;
              fcs = this.eventHandlers.formStatusChanged;
              if (!fcs) {
                scaffold = this.feature.options.scaffold || {};
                fsc = (_ref1 = scaffold.handlers) != null ? _ref1.formStatusChanged : void 0;
              }
              if (_.isFunction(fsc)) {
                getFormData(this);
                return fsc.call(this, this.model.toJSON(), $(e.target));
              }
            };
            view.forms = data;
            feature.views['forms:' + view.baseName] = view;
            return deferred.resolve(view);
          }
        });
        return deferred;
      }
    };
  });

}).call(this);
