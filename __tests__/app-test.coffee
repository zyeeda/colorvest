jest.dontMock '../dist/app/sum'
describe 'avg', ->
	it '4 + 2 avg is 3', ->
    	avg = require '../dist/app/sum'
    	expect(avg 4, 2).toBe 3

jest.dontMock '../dist/core/layout'

describe 'layout', ->
	it 'layout toBeDefined', ->
		Layout = require '../dist/core/layout'
		layout = new Layout name: 'test', parent: 'hello'
		expect(layout).toBeDefined()
		expect(layout.getParent()).toBe 'hello'
