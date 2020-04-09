module.exports = LinterB =
  config:
    probcliPath:
      title: 'ProB CLI Executable Path'
      description: 'The path to probcli'
      type: 'string'
      default: 'probcli'
    probCheckWD:
      title: 'Check Well-Definedness POs'
      type: 'boolean'
      description: 'Generate WD (Well-Definedness) POs (Proof Obligations) and try and discharge them (requires probcli 1.10.0-nightly or newer)'
      default: false
    probStricterStaticChecks:
      title: 'Stricter Static Checks'
      type: 'boolean'
      description: 'Type check DEFINITIONS, stricter clash warnings, ...'
      default: true
  provideLinter: ->
    LinterProvider = require './linter-provider'
    provider = new LinterProvider()
    return {
      grammarScopes: ['source.classicalb.rules', 'source.classicalb']
      scope: 'file'
      lint: provider.lint
      lintsOnChange: false
      name: 'ProB'
    }
