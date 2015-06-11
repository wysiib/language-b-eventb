describe 'Classical B tickets', ->
  grammar = null

  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage('language-b-eventb')

    runs ->
      grammar = atom.grammars.grammarForScopeName('source.classicalb')

  it 'parses the grammar', ->
    expect(grammar).toBeTruthy()
    expect(grammar.scopeName).toBe 'source.classicalb'

  describe "issue 1", ->
    it "should not color keywords in strings", ->
      {tokens} = grammar.tokenizeLine 'x = "DOWN"'
      expect(tokens[0]).toEqual value: 'x', scopes: [ 'source.classicalb', 'identifier.classicalb' ]
      expect(tokens[2]).toEqual value: '=', scopes: [ 'source.classicalb', 'keyword.operator.assignment.classicalb' ]
      expect(tokens[4]).toEqual value: '"', scopes: [ 'source.classicalb', 'string.quoted.double.classicalb', 'punctuation.definition.string.begin.classicalb' ]
      expect(tokens[5]).toEqual value: 'DOWN', scopes: [ 'source.classicalb', 'string.quoted.double.classicalb' ]
      expect(tokens[6]).toEqual value: '"', scopes: [ 'source.classicalb', 'string.quoted.double.classicalb', 'punctuation.definition.string.end.classicalb' ]

  describe "issue 1", ->
    it "should highlight the machine keyword", ->
      {tokens} = grammar.tokenizeLine 'MACHINE test\nVARIABLES x\nEND\n'
      expect(tokens[0]).toEqual value: 'MACHINE', scopes: [ 'source.classicalb', 'keyword.other.machineclause.classicalb' ]
      expect(tokens[2]).toEqual value: 'test', scopes: [ 'source.classicalb', 'identifier.classicalb' ]
      expect(tokens[4]).toEqual value: 'VARIABLES', scopes: [ 'source.classicalb', 'keyword.other.machineclause.classicalb' ]
      expect(tokens[6]).toEqual value: 'x', scopes: [ 'source.classicalb', 'identifier.classicalb' ]
      expect(tokens[8]).toEqual value: 'END', scopes: [ 'source.classicalb', 'keyword.control.classicalb' ]
