// Generated by CoffeeScript 1.4.0
(function() {

  define(['config', 'underscore'], function(projectConfig, _) {
    var config;
    config = {
      applicationName: 'app',
      templateSuffix: '.html',
      featureContainer: 'body',
      urlPrefix: 'invoke',
      modelDefinitionPath: 'definition',
      routerFileName: 'routers',
      scriptRoot: '/scripts',
      appRoot: 'app',
      helperPath: 'invoke/helper',
      coalaFeaturesPath: 'coala/features',
      urlPrefix: 'invoke/scaffold',
      minimumResultsForSearch: 10,
      folders: {
        layout: '__layouts__',
        view: '__views__',
        model: '__models__',
        collection: '__collections__',
        handler: '__handlers__',
        template: '__templates__'
      },
      getPath: function(feature, type, path) {
        var root;
        if (path.charAt(0) === '/') {
          root = true;
        }
        if (root === true) {
          path = path.substring(1);
        }
        return (root ? '/' : feature.baseName + '/') + config.folders[type] + '/' + path;
      }
    };
    return _.extend(config, projectConfig);
  });

}).call(this);
