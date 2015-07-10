marked = require('marked')
hljs = require('highlight.js')
sysPath = require('path')

module.exports = class MarkdownCompiler
  brunchPlugin: yes
  type: 'template'
  extension: 'md'
  pattern: /(\.(markdown|mdown|mkdn|md|mkd|mdwn|mdtxt|mdtext|text))$/
  customWrapper: 'amd'
  moduleName: (name)-> name

  constructor: (config) ->
    languages = Object.keys(hljs.LANGUAGES)
    options = Object.create(config.marked ? null)

    # If highlight isn't defined in config then use default Highlight.js
    unless 'highlight' of options
      options.highlight = (code, lang) ->
        if lang is 'auto'
          hljs.highlightAuto(code).value
        else if languages.indexOf(lang) isnt -1
          hljs.highlight(lang, code).value

    # Set marked options
    marked.setOptions(options)

  compile: (data, path, callback) ->
    try
      ext  = sysPath.extname(path)
      name = @moduleName( sysPath.join(sysPath.dirname(path), sysPath.basename(path, ext)).replace(/[\\]/g, '/') )
      result = JSON.stringify(marked(data))
      if @customWrapper is 'amd'
        result = """
define("#{name}", ["exports"], function(__exports__) {
  "use strict";
  __exports__["default"] = #{result};
});
"""
      else
        result = """
var temp = #{templateFunc}(#{content});
if (module && module.exports) {
  module.exports = Ember.TEMPLATES["#{templateName}"] = temp;
}
"""
    catch err
      error = err
    finally
      callback(error, result)
