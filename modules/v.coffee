####NOTDELETE########
### 
# @require jquery
# @require bootstrap
# @require underscore
# @require backbone
# @require react
### 
####COLORVEST########

v = window.v = {}
v.$ = $
v._ = _
v.b = Backbone
v.r = React

delete $
delete _ 
delete Backbone
delete React

module.exports = v
