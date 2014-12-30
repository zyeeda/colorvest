_ = require 'lodash'

# 大小列表
sizeMapping =
    large: 'lg'
    default: ''
    small: 'sm'
    xsmall: 'xs'

typeMapping =
    button: 'btn'
    input: 'input'

widgetHelper =
    # 合并 class
    joinClasses: (className = '', others...) ->
        names = []
        names.push name for name in others
        names.push className if className isnt ''
        names.join ' '

    # 获取高度
    getHeightSize: (type="input", size="default") ->
        sz = sizeMapping[size]
        tp = typeMapping[type]

        heightSize = tp + "-" + sz if sz? and tp?
        heightSize = '' if heightSize?
        heightSize

module.exports = widgetHelper
