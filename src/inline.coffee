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

###*
# CreoleInline represents different sorts of inline markup elements, such as
# **bold** text, //italic// text, or inline nowiki blocks.
#
# @class CreoleInline
# @constructor
# @param {String} [type] Inline element type (One of 'bold', 'italic', or
#   'nowiki', or simply 'text')
# @param {String} text Text content. If 'type' is present and 'type' is 'text',
#   then this text will not be processed, and will be considered to simply be
#   a span.
###
class CreoleInline
  constructor: (type, text) ->
    if not text?
      text = type
      type = undefined
    if type? and not type in ['bold', 'italic', 'nowiki', 'text']
      throw new TypeError 'Expected type to be either \'bold\', \'italic\', ' +
        'or \'nowiki\' or \'text\''
    this.elem = type
    this.children = []
    if text? and typeof text is 'string' and type isnt 'text'
      this.children = CreoleInline.__process text
    else this.text = text || ""

CreoleInline::element = 'inline'

###*
# Parses a string, returning an array of processed inline objects. This function
# is recursive. This function is private.
#
# @static
# @private
# @param {String} text to process
###
CreoleInline.__process = (text) ->
  pos = 0
  children = []
  while pos < text.length
    min = Math.min
      
    next = (str, reg, start) ->
      start = start || 0
      idx = str.substring(start).search reg
      if idx < 0 then -1 else idx + start
    bold = next text, /\*\*/, pos
    ital = next text, /(?:(?!\:))\/\//, pos
    code = next text, /\{\{\{/, pos
    type = min bold, ital, code
    if type < 0
      # If we didn't find anything, the rest of the string is a text node.
      children.push new CreoleInline 'text', text
      return children
    else
      if type > pos then children.push new CreoleInline 'text',
        text.substring pos, type
      nextBold = next text, /\*\*/, bold
      nextItal = next text, /(?:(?!\:))\/\//, ital
      nextCode = next text, /\{\{\{/, code
      nextType = min nextBold, nextItal, nextCode
      if type is bold and nextBold >= 0
        children.push new CreoleInline 'bold', text.substring bold, nextBold
      else if type is ital and nextItal >= 0
        children.push new CreoleInline 'italic', text.substring ital, nextItal
      else if type is code and nextCode >= 0
        children.push new CreoleInline 'code', text.substring code, nextCode
      else
        break
    pos = nextType + if nextType is nextCode then 3 else 2

  # Return the children
  children

# @if BUILD_TYPE === 'node'
module.exports = exports = CreoleInline
# @endif