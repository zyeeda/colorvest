StackApp = require './app/stack'

Colorvest = StackApp: StackApp
Colorvest.utils = joinClasses: require 'colorvest/utils/widget-helper'

window.Colorvest = Colorvest
