_ = require 'lodash'
# 高度列表
heightSizingMapping =
    large: 'input-lg'
    default: ''
    small: 'input-sm'
    xsmall: 'input-sm'

widgetHelper =
	joinClasses: (className = '', others...) ->
	    names = []
	    names.push name for name in others
	    names.push className if className isnt ''
	    if not _.isEmpty names
	    	return  names.join ' '
	    ''


	# 获取高度
	getHeightSizing: (sizing) ->
	    heightSizing = heightSizingMapping[sizing]
	    heightSizing = '' if _.isUndefined sizing
	    heightSizing

module.exports = widgetHelper
