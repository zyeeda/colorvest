define
    showFeature: ->
        viewport = @feature.views['content'].components[0]
        console.log viewport
        viewport.showFeature
            path: 'test/bar'
            name: 'Boo'
            icon: 'http://fakeimg.pl/48'
