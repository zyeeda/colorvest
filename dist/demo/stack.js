var App, app;

App = require('../app/stack');

app = window.app = new App({
  regions: [
    {
      region: 'first',
      height: 50,
      content: React.createElement("div", {
        "style": {
          height: '100%',
          background: 'yellow'
        }
      }, "first")
    }, {
      region: 'second',
      height: 200,
      content: React.createElement("div", {
        "style": {
          height: '100%',
          background: 'blue'
        }
      }, "second")
    }, {
      region: 'third',
      height: 150,
      content: React.createElement("div", {
        "style": {
          height: '100%',
          background: 'green'
        }
      }, "third")
    }, {
      region: 'four',
      height: 150,
      content: React.createElement("div", {
        "style": {
          height: '100%',
          background: 'pink'
        }
      }, "four")
    }
  ]
});

app.start();
