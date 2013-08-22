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
CreoleHeading = require('./heading')
CreoleInline = require('./inline')
CreoleList = require('./list')
CreoleRuler = require('./ruler')
CreoleTable = require('./table')
CreoleText = require('./text')
# @endif

###*
# CreoleParser class, responsible for transforming Creole dialect Wiki markup
# into an abstract syntax tree, which can be processed by an application.
#
# @class CreoleParser
# @constructor
# @param {Object} [options] configuration options for the Parser.
#   The `escape` parameter enables the caller to control whether or not HTML is
#   escaped prior to parsing. Disabling this could provide a slight performance
#   improvement, in some cases.
###
class CreoleParser
  constructor: (options) ->
    options = options or {}
    this.escape = if options.escape? then !!options.escape else true

###*
# Return the next block element from a stream of text, so that it can be
# converted to markup.
#
# @private
# @method __nextBlock
# @param {Object} textref Object containing key 'text', whose value must
#   be a String.
# @return {Object} Processed block markup element, one of either {CreoleNoWiki},
#   {CreoleHeading}, {CreoleRuler}, {CreoleList}, {CreoleTable} or
#   {CreoleText}.
###

CreoleParser::__nextBlock = (textref) ->
  #
  # Skip any empty blocks
  #
  match = textref.text.match /^(\s*\n*)+/m
  if match? then textref.text = textref.text.substr match[0].length
  
  #
  # It might be a NoWiki block -- If we start with '{{{<NEWLINE>' and encounter
  # an '}}}' later in the file, treat it as a NoWiki.
  #
  match = textref.text.match /^\{\{\{(\n)((?!(\}\}\})|$)*)\}\}\}/m
  if match?
    textref.text = textref.text.substr match[0].length
    return this.__processNoWiki(match[4])

  #
  # Single-line blocks are limited to a single line:
  # - Headings
  match = textref.text.match /\s*(={1,6})(.+)$/
  if match?
    textref.text = textref.text = textref.text.substr match[0].length
    return this.__processHeading match[1], match[2]

  # - HorizontalRule
  match = textref.text.match /^\s*-{4,}.*$/
  if match?
    textref.text = textref.text.substr match[0].length
    return new CreoleHorizontalRule()

  # - List block
  #   Return a collection of lines starting with [*#] -- List elements don't
  #   need to occur at the start of the line, unlike tables (according to the)
  #   ANTLR markup
  match = textref.text.match /^(\s*[*#]+(?!\n)*\n|$)+/
  if match?
    #
    # AMBIGUITY HANDLING:
    #   A 2-level unordered list looks like a BOLD tag. To deal with this, we'll
    #   walk each line in the list block, and make sure that we have an even
    #   uneven number of '**' pairs. If there is an even number of double-stars,
    #   then truncate the list.
    unorderedLevel2 = (text) ->
      front = text.replace /^\s*([*#])+.*$/, '$1'
      (front.match(/(?:^|#)(\*\*(?:(?!\*)))/) || ['']).length - 1
    lines = match[0].split '\n'
    for i in [0..lines.length]
      line = lines[i]
      # If we're on an unordered level 2 list item, then we need to avoid this
      # ambiguity:
      level2 = unorderedLevel2 line
      if level2
        count = (line.replace(/^\s*[*#]+/, '').match(/^([^*]\*\*[^*])/g) ||
          ['']).length - 1
        endsWithNewline = match[0].charAt(match[0].length-1) is '\n'
        # We've got an uneven number of '**' bold tags, so we're going to say
        # that this isn't a list item, and cut the block off here.
        if count % 2 isnt 0
          match[0].replace lines.slice(i).join '\n', ''
          if endsWithNewline then match[0] += '\n'
    textref.text = textref.text.substr match[0].length
    if match[0].length > 1
      return this.__processList match[0]
  
  # - Table block
  #   These are weird, because according to the ANTLR grammar, the first row
  #   need not occur at the beginning of the line, but subsequent rows must.
  #   I'm not sure if this was an oversight, or what.
  #
  #   The structure is basically ^\s*(|(?!\n|$)*(\n|$))+/m
  #   Any line which begins with a PIPE is a part of a table block.
  match = textref.text.match /^\s*(\|(?!\n|$)*(\n|$))+/m
  if match?
    textref.text = textref.text.substr match[0].length
    return this.__processTable match[0]

  # - Text paragraph
  #   Any non-blank entry where the above rules don't match, basically.
  return this.__processText textref

###*
# Return a CreoleNoWiki object, containing text which is meant to be unescaped
# and not treated as Creole markup.
#
# @private
# @method __processNoWiki
# @param {String} text NoWiki internal text (between {{{ and }}})
# @return {Object} CreoleNoWiki
###
CreoleParser::__processNoWiki = (text) ->
  new CreoleNoWiki text
  
###*
# Return a CreoleHeading object, containing the numeric heading 'level', and
# the text content of the heading.
#
# It is assumed that there is no leading or trailing whitespace in the 'level'
# parameter, as simply the length of it is used to determine heading level.
#
# Leading and trailing whitespace (and trailing '=') are removed from the
# heading.
#
# @private
# @method __processHeading
# @param {String} level the string of '=' signs which preface the heading
#   which is used to determine the heading level (1-6)
# @param {String} heading the content of the Heading. Trailing '=' or
#   whitespace before the end of the string will be removed
# @return {Object} CreoleHeading
###
CreoleParser::__processHeading = (level, heading) ->
  heading = heading.replace /\s*=*$/, ''
  new CreoleHeading level.length, heading.replace /^\s*/, ''

###*
# Return a CreoleList object, which is itself a tree of CreoleLists. each
# child element (list item) of a CreoleList will be either CreoleList or
# CreoleText.
#
# @private
# @method __processList
# @param {String} text the text containing one or more ordered or unordered
#   list items.
# @return {Object} CreoleList
###
CreoleParser::__processList = (text) ->
  lines = text.split '\n'
  # Start first item
  line = lines[0]
  header = line.match(/^\s*([*#])/)[1]
  list = new CreoleList header.charAt(0)
  current = list
  for i in [1...header.length]
    item = new CreoleList header.charAt(i), current
    current.items.push item
    current = item
  for line in lines
    match = line.match(/^\s*([*#])\s*(.*)$/)
    newheader = match[1]
    text = match[2]
    
    # If 'current' has changed, update
    if header isnt newheader
      pass

    # Append the child
    current.items.push new CreoleInline text

  # Return the processed CreoleList
  list

# @if BUILD_TYPE === 'node'
module.exports = exports = CreoleParser
# @endif
