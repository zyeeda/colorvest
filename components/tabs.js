// Generated by CoffeeScript 1.4.0
(function() {

  define(['jquery', 'underscore', 'coala/coala', 'jqueryui/tabs'], function($, _, coala) {
    var proto;
    proto = {
      addTab: function(options) {
        var addFn, tabTemplate,
          _this = this;
        addFn = this.$el.tabs('option', 'add');
        tabTemplate = this.$el.tabs('option', 'tabTemplate');
        this.$el.tabs('option', 'add', function(event, ui) {
          var $panel;
          addFn(event, ui);
          if (options.selected === true) {
            _this.$el.tabs('select', '#' + ui.panel.id);
          }
          if (options.fit === true) {
            $panel = $(ui.panel);
            $panel.innerHeight($panel.parent().height());
            return $panel.addClass('ui-tabs-panel-fit');
          }
        });
        if (options.closable === true) {
          this.$el.tabs('option', 'tabTemplate', '<li><a href="#{href}">#{label}</a><i class="ui-icon ui-icon-close"></i></li>');
        }
        this.$el.tabs('add', options.url, options.label, options.index);
        if (options.selected === true) {
          this.$el.tabs('option', 'add', addFn);
        }
        if (options.closable === true) {
          this.$el.tabs('option', 'tabTemplate', tabTemplate);
        }
      },
      removeTab: function(index) {
        if (index == null) {
          index = this.$el.tabs('option', 'selected');
        }
        this.$el.tabs('remove', index);
      },
      selectTab: function(index, options) {
        if (this.tabExists(index)) {
          this.$el.tabs('select', index);
          return true;
        }
        if (options != null) {
          if (_.isString(options)) {
            options = {
              url: index,
              label: options,
              selected: true
            };
          }
          if (options.url == null) {
            options.url = index;
          }
          this.addTab(options);
        }
        return false;
      },
      tabExists: function(index) {
        return $(index).length !== 0;
      },
      disableTab: function(index) {
        if (index == null) {
          index = this.$el.tabs('option', 'selected');
        }
        this.$el.tabs('disable', index);
      },
      enableTab: function(index) {
        if (index == null) {
          index = this.$el.tabs('option', 'selected');
        }
        this.$el.tabs('enable', index);
      },
      disable: function() {
        this.$el.tabs('disable');
      },
      enable: function() {
        this.$el.tabs('enable');
      },
      length: function() {
        return this.$el.tabs('length');
      },
      dispose: function() {
        $('ul.ui-widget-header', this.$el).off('click');
        this.$el.removeData('zui.tabs');
        this.$el.tabs('destroy');
      }
    };
    return coala.registerComponentHandler('tabs', (function() {}), function(el, opt, view) {
      /*
              # options
              #   hashBase
              #   router
      */

      var $el, addFn, options, selectFn, showFn;
      options = _.extend({}, opt);
      addFn = options.add;
      options.add = function(event, ui) {
        var $panel;
        $panel = $(ui.panel);
        $panel.appendTo($panel.prev());
        if (addFn != null) {
          return addFn(event, ui);
        }
      };
      showFn = options.show;
      options.show = function(event, ui) {
        if ($.layout != null) {
          $.layout.callbacks.resizeTabLayout(event, ui);
        }
        if (showFn != null) {
          return showFn(event, ui);
        }
      };
      if (options.router != null) {
        selectFn = options.select;
        options.select = function(event, ui) {
          var hashBase, href, _ref;
          hashBase = (_ref = options.hashBase) != null ? _ref : '';
          href = $(ui.tab).attr('href');
          if (href.indexOf('#' === 0)) {
            href = href.substring(1);
          }
          href = "" + hashBase + href;
          if (href !== window.location.hash) {
            options.router.setLocation(href);
            return false;
          }
          if (selectFn != null) {
            return selectFn(event, ui);
          }
        };
      }
      $el = $(el);
      if ($el.data('zui.tabs') == null) {
        $el.tabs(options);
        $('.ui-tabs-nav', $el).on('click', '.ui-icon-close', function() {
          var index;
          index = $('li', $el).index($(this).parent());
          return $el.tabs('remove', index);
        });
        $el.data('zui.tabs', $.extend({
          $el: $el
        }, proto));
      }
      return $el.data('zui.tabs');
    });
  });

}).call(this);
