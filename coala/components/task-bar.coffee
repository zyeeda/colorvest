define [
    'underscore',
    'coala/coala',
    'coala/vendors/jquery/jquery.carouFredSel'
], (_, coala) ->

    pinTemplate = '''
    <div class="coala-taskbar-pin">
        <ul>
            <li>
                <img src="http://fakeimg.pl/48/" alt="所有应用" />
                <div>所有应用</div>
            </li>
            <li>
                <img src="http://fakeimg.pl/48/" alt="首页" />
                <div>首页</div>
            </li>
        </ul>
    </div>
    '''

    carouselTemplate = '''
    <div class="coala-taskbar-carousel">
        <ul></ul>
        <a href="javascript:void(0);" class="coala-taskbar-prev"><i class="icon-chevron-left"></i></a>
        <a href="javascript:void(0);" class="coala-taskbar-next"><i class="icon-chevron-right"></i></a>
    </div>
    '''

    coala.registerComponentHandler 'task-bar', (->), (el, options, view) ->

        defaultOptions = {}

        options = _.extend defaultOptions, options

        pinWrapper = $(pinTemplate).appendTo el
        pinContainer = pinWrapper.children('ul')
        carouselWrapper = $(carouselTemplate).appendTo el
        carouselContainer = carouselWrapper.children('ul')

        carouselWrapper.css 'padding-left', pinWrapper.width()

        carouselContainer.carouFredSel
            circular: false
            infinite: false
            auto: false
            align: 'left'
            prev:
                button: carouselContainer.parent().children('.coala-taskbar-prev')
            next:
                button: carouselContainer.parent().children('.coala-taskbar-next')
            height: el.height()
            onCreate: ->
                $(window).on 'resize', ->
                    carouselContainer.trigger 'updateSizes'

        carouselContainer.delegate '.icon-remove-sign', 'click', ->
            li = $(this).parents('li')
            li.animate(
                opacity: 0
            , 500).animate(
                width: 0,
            , 500, ->
                carouselContainer.trigger 'removeItem', li
            )

        taskBar =
            add: (items) ->
                items = [items] if !_.isArray items

                for item in items
                    liTemplate = """
                    <li>
                        <div class="coala-taskbar-carousel-icon">
                            <img src="#{item.icon}" alt="#{item.name}" />
                            <div><i class="icon-remove-sign"></i></div>
                        </div>
                        <div class="coala-taskbar-carousel-text">#{item.name}</div>
                    </li>
                    """
                    carouselContainer.trigger 'insertItem', [liTemplate]

        taskBar.add [
            icon: 'http://fakeimg.pl/48/'
            name: '人力资源管理人力资源管理'
        ,
            icon: 'http://fakeimg.pl/48/'
            name: '资产管理'
        ,
            icon: 'http://fakeimg.pl/48/'
            name: '项目管理'
        ,
            icon: 'http://fakeimg.pl/48/'
            name: '目标管理'
        ,
            icon: 'http://fakeimg.pl/48/'
            name: '客户关系管理'
        ,
            icon: 'http://fakeimg.pl/48/'
            name: '财务管理'
        ,
            icon: 'http://fakeimg.pl/48/'
            name: 'XX管理'
        ,
            icon: 'http://fakeimg.pl/48/'
            name: 'XX管理'
        ,
            icon: 'http://fakeimg.pl/48/'
            name: 'XX管理'
        ,
            icon: 'http://fakeimg.pl/48/'
            name: 'XX管理'
        ,
            icon: 'http://fakeimg.pl/48/'
            name: 'XX管理'
        ,
            icon: 'http://fakeimg.pl/48/'
            name: 'XX管理'
        ,
            icon: 'http://fakeimg.pl/48/'
            name: 'XX管理'
        ,
            icon: 'http://fakeimg.pl/48/'
            name: 'XX管理'
        ,
            icon: 'http://fakeimg.pl/48/'
            name: 'XX管理'
        ,
            icon: 'http://fakeimg.pl/48/'
            name: 'XX管理'
        ,
            icon: 'http://fakeimg.pl/48/'
            name: 'XX管理'
        ,
            icon: 'http://fakeimg.pl/48/'
            name: 'XX管理'
        ]

        taskBar
