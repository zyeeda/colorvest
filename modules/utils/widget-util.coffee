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

module.exports =
    # 获取高度
    getHeightSize: (type="input", size="default") ->
        sz = sizeMapping[size]
        tp = typeMapping[type]

        heightSize = tp + "-" + sz if sz? and tp?
        heightSize = '' if heightSize?
        heightSize

    getColumnSize: (size='') ->
        s = size
        s = 'col-sm-' + s if s isnt ''
        s
        
    getClassName: (className='')->
        cn = className
        cn

