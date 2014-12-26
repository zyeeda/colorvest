count = require './count'

sum = (value1, value2) ->
	value1 + value2

avg = (value1, value2) ->
	sum(value1, value2) / count
	
module.exports = avg