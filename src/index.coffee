marked = require('marked')
hljs = require('highlight.js')
umd = require('umd-wrapper')

module.exports = class MarkdownCompiler
  brunchPlugin: yes
  type: 'template'
  extension: 'md'
  pattern: /(\.(markdown|mdown|mkdn|md|mkd|mdwn|mdtxt|mdtext|text))$/

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
      result = umd(JSON.stringify(marked(data)))
      console.log(result, callback);
    catch err
      error = err
    finally
      callback(error, result)
