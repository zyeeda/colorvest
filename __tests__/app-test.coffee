jest.dontMock '../src/app/sum'
describe 'avg', ->
	it '4 + 2 avg is 3', ->
    	avg = require '../src/app/sum'
    	expect(avg 4, 2).toBe 3

jest.dontMock '../src/core/layout'

describe 'layout', ->
	it 'layout toBeDefined', ->
		Layout = require '../src/core/layout'
		layout = new Layout name: 'test', parent: 'hello'
		expect(layout).toBeDefined()
		expect(layout.getParent()).toBe 'hello'
