_ = require 'lodash'

# TODO mapping 写成常量
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
    # 获取高度设置
    getHeightSize: (type="input", size="default") ->
        sz = sizeMapping[size]
        console.warn "不存在与 '#{size}' 对应的设置，请查看 heightSize 设置是否正确。" if not sz?
        tp = typeMapping[type]
        console.error "参数 type 的类型不正确，error(type=#{type})。" if not tp?

        heightSize = tp + "-" + sz if sz? and tp?
        heightSize = heightSize || ''
        heightSize

    # 获取宽度设置
    getColumnSize: (size='') ->
        s = size
        s = 'col-sm-' + s if s isnt ''
        s

    # 获取 className，如果不存在则返回 ''
    getClassName: (className='')->
        cn = className
        cn

