define
    layout:
        regions:
            viewport: 'viewportRegion'

    views: [
        name: 'inline:viewport'
        region: 'viewport'
        events:
            'this#launcher:launch': 'launchApp'
            'this#viewport:close-feature': 'closeFeature'
        components: [
            type: 'launcher'
            selector: 'launcherEntry'
            data: [
                {id: 'f1', name: 'Foo', icon: ''}
                {id: 'f2', name: 'Row 1', icon: '', parent: {id: 'f1'}}
                {id: 'f3', name: 'Foo', icon: 'coala-fakeimg-48', path: 'test/foo', parent: {id: 'f2'}}
                {id: 'f4', name: 'Item 2', icon: 'coala-fakeimg-48', parent: {id: 'f2'}}

                {id: 'b1', name: 'Bar', icon: ''}
                {id: 'b2', name: 'Row 2', icon: '', parent: {id: 'b1'}}
                {id: 'b3', name: 'Row 3', icon: '', parent: {id: 'b1'}}
                {id: 'b4', name: 'Item 1', icon: 'coala-fakeimg-48', parent: {id: 'b2'}}
                {id: 'b5', name: 'Bar', icon: 'coala-fakeimg-48', path: 'test/bar', parent: {id: 'b3'}}

                {id: 'c1', name: 'Only two level', icon: ''}
                {id: 'c2', name: 'Row 4', icon: '', parent: {id: 'c1'}}
                {id: 'c3', name: 'Row 5', icon: '', parent: {id: 'c1'}}
                {id: 'c4', name: 'Row 6', icon: '', parent: {id: 'c1'}}
                {id: 'c5', name: 'Row 2', icon: '', parent: {id: 'c1'}}
            ]
        ,
            type: 'viewport'
            selector: 'viewport'
        ]
    ]

