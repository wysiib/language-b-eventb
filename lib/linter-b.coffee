module.exports = LinterB =
  config:
    probcliPath:
      title: 'ProB CLI Executable Path'
      description: 'The path to probcli'
      type: 'string'
      default: 'probcli'
  provideLinter: ->
    LinterProvider = require './linter-provider'
    provider = new LinterProvider()
    return {
      grammarScopes: ['source.classicalb']
      scope: 'file'
      lint: provider.lint
      lintOnFly: false
    }
