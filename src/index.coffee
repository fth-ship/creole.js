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
# http://www.wikicreole.org/wiki/Creole1.0
#

# @if BUILD_TYPE === 'node'
module.exports = exports =
  CreoleHeading: require('./heading')
  CreoleInline: require('./inline')
  CreoleList: require('./list')
  CreoleParser: require('./parser')
  CreoleRuler: require('./ruler')
  CreoleTable: require('./table')
  CreoleText: require('./text')
# @endif
# @if BUILD_TYPE === 'browser'
global.CreoleHeading = CreoleHeading
global.CreoleInline = CreoleInline
global.CreoleList = CreoleList
global.CreoleParser = CreoleParser
global.CreoleRuler = CreoleRuler
global.CreoleTable = CreoleTable
global.CreoleText = CreoleText
# @endif