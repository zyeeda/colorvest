jest.dontMock '../modules/app/sum.coffee'
describe 'sum', ->
	it 'adds 1 + 2 to equal 3', ->
    	sum = require '../modules/app/sum.coffee'
    	expect(sum 1, 2).toBe 3

jest.dontMock '../modules/core/layout.coffee'
describe 'layout', ->
	it 'layout toBeDefined', ->
		Layout = require '../modules/core/layout.coffee'
		layout = new Layout name: 'test', parent: 'hello'
		expect(layout).toBeDefined()
		expect(layout.getParent()).toBe 'hello'
