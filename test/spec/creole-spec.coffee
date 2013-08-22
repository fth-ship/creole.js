#
# The MIT License (MIT)
#
# Copyright (c) 2013 Caitlin Potter and Contributors
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#

describe 'CreoleParser', ->
  it 'should be an object', ->
    expect(typeof CreoleParser is 'function').to.be.ok
    parser = new CreoleParser()
    expect(parser).not.be.null
    expect(parser instanceof CreoleParser).to.be.ok

  describe '__processList', ->
    parser = new CreoleParser()
    describe 'ordered list', ->
      list = parser.__processList '#one\n#two\n#three\n#four'
      it 'should return a CreoleList', ->
        expect(list).to.exist
        expect(typeof list is 'object')
        expect(list instanceof CreoleList).to.be.ok

      it 'should be an unordered list', ->
        expect(list.type).to.equal 'ordered'
    
      it 'should have four items', ->
        expect(list.items.length).to.equal 4

      it 'should contain \'one, two, three, four\'', ->
        expect(list.items[0].children[0].text).to.equal 'one'
        expect(list.items[1].children[0].text).to.equal 'two'
        expect(list.items[2].children[0].text).to.equal 'three'
        expect(list.items[3].children[0].text).to.equal 'four'
    describe 'unordered list', ->
      list = parser.__processList '*one\n*two\n*three\n*four'
      it 'should return a CreoleList', ->
        expect(list).to.exist
        expect(typeof list is 'object')
        expect(list instanceof CreoleList).to.be.ok

      it 'should be an unordered list', ->
        expect(list.type).to.equal 'unordered'
    
      it 'should have four items', ->
        expect(list.items.length).to.equal 4

      it 'should contain \'one, two, three, four\'', ->
        expect(list.items[0].children[0].text).to.equal 'one'
        expect(list.items[1].children[0].text).to.equal 'two'
        expect(list.items[2].children[0].text).to.equal 'three'
        expect(list.items[3].children[0].text).to.equal 'four'