_ = require 'lodash'
# 高度列表
heightSizeMapping =
    large: 'input-lg'
    default: ''
    small: 'input-sm'
    xsmall: 'input-sm'

sizeMapping = 
        large: 'btn-lg'
        small: 'btn-sm'
        xsmall: 'btn-xs'
        default: ''

widgetHelper =
    joinClasses: (className = '', others...) ->
        names = []
        names.push name for name in others
        names.push className if className isnt ''
        # if not _.isEmpty names
        #     return  names.join ' '
        # ''
        names.join ' '


    # 获取高度
    getHeightSize: (sizing) ->
        heightSizing = heightSizeMapping[sizing]
        heightSizing = '' if _.isUndefined sizing
        heightSizing

    getSize: (s) ->
        size = sizeMapping[s]
        size = '' if _.isUndefined s
        size

module.exports = widgetHelper
