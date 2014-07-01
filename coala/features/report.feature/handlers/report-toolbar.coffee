define ['jquery'], ($) ->
    birt_toolbar_click: (e) ->
        if window.frames[0] && window.frames[0].BirtToolbar
            window.frames[0].BirtToolbar.prototype.__neh_click e
        else
            app.error '报表服务运行错误，请联系管理员!'
