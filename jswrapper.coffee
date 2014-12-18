Colorvest = require 'Colorvest'

if typeof exports is 'object'
	module.exports = Colorvest
else if typeof define is 'function' and define.amd
	define -> Colorvest
else 
	window.Colorvest = Colorvest