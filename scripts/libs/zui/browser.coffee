_define = ($) ->
    $html = $ 'html'

    ->
        if $.browser.msie is true
            $html.addClass 'ie'
            $html.addClass "ie#{parseInt $.browser.version}"
            return
        if $.browser.webkit is true
            $html.addClass 'webkit'
            return
        if $.browser.mozilla is true
            $html.addClass 'gecko'
            return
        if $.browser.opera is true
            $html.addClass 'opera'
            return

if define? and define.amd?
    define ['jquery'], _define
else
    window.zui ?= {}
    window.zui.detectBrowser = _define $
