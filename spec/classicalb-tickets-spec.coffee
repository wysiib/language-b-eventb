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

  describe "wrong highlights", ->
    it "should not color keywords in strings (issue 1)", ->
      {tokens} = grammar.tokenizeLine 'x = "DOWN"'
      expect(tokens[0]).toEqual value: 'x', scopes: [ 'source.classicalb', 'identifier.classicalb' ]
      expect(tokens[2]).toEqual value: '=', scopes: [ 'source.classicalb', 'keyword.operator.assignment.classicalb' ]
      expect(tokens[4]).toEqual value: '"', scopes: [ 'source.classicalb', 'string.quoted.double.classicalb', 'punctuation.definition.string.begin.classicalb' ]
      expect(tokens[5]).toEqual value: 'DOWN', scopes: [ 'source.classicalb', 'string.quoted.double.classicalb' ]
      expect(tokens[6]).toEqual value: '"', scopes: [ 'source.classicalb', 'string.quoted.double.classicalb', 'punctuation.definition.string.end.classicalb' ]
    it "should not color keywords when they are a part of identifiers (issue 5)", ->
      {tokens} = grammar.tokenizeLine 'Sort(yy) = PRE yy:ID THEN xx:=yy END'
      expect(tokens[0]).toEqual value: 'Sort', scopes: [ 'source.classicalb', 'identifier.classicalb' ]
      expect(tokens[2]).toEqual value: 'yy', scopes: [ 'source.classicalb', 'identifier.classicalb' ]
      expect(tokens[4]).toEqual value: '=', scopes: [ 'source.classicalb', 'keyword.operator.assignment.classicalb' ]
      expect(tokens[6]).toEqual value: 'PRE', scopes: [ 'source.classicalb', 'keyword.control.classicalb' ]
      expect(tokens[8]).toEqual value: 'yy', scopes: [ 'source.classicalb', 'identifier.classicalb' ]
      expect(tokens[9]).toEqual value: ':', scopes: [ 'source.classicalb', 'keyword.operator.set.classicalb' ]
      expect(tokens[10]).toEqual value: 'ID', scopes: [ 'source.classicalb', 'identifier.classicalb' ]
      expect(tokens[12]).toEqual value: 'THEN', scopes: [ 'source.classicalb', 'keyword.control.classicalb' ]
      expect(tokens[14]).toEqual value: 'xx', scopes: [ 'source.classicalb', 'identifier.classicalb' ]
      expect(tokens[15]).toEqual value: ':=', scopes: [ 'source.classicalb', 'keyword.operator.assignment.classicalb' ]
      expect(tokens[16]).toEqual value: 'yy', scopes: [ 'source.classicalb', 'identifier.classicalb' ]
      expect(tokens[18]).toEqual value: 'END', scopes: [ 'source.classicalb', 'keyword.control.classicalb' ]

  describe "missing highlights", ->
    it "it should highlight the machine keyword (issue 2)", ->
      {tokens} = grammar.tokenizeLine 'MACHINE test\nVARIABLES x\nEND\n'
      expect(tokens[0]).toEqual value: 'MACHINE', scopes: [ 'source.classicalb', 'meta.machine.classicalb', 'keyword.other.machine.classicalb' ]
      expect(tokens[2]).toEqual value: 'test', scopes: [ 'source.classicalb', 'meta.machine.classicalb', 'identifier.classicalb' ]
      expect(tokens[4]).toEqual value: 'VARIABLES', scopes: [ 'source.classicalb', 'meta.machine.classicalb', 'keyword.other.machineclause.classicalb' ]
      expect(tokens[6]).toEqual value: 'x', scopes: [ 'source.classicalb', 'meta.machine.classicalb', 'identifier.classicalb' ]
      expect(tokens[8]).toEqual value: 'END', scopes: [ 'source.classicalb', 'meta.machine.classicalb', 'keyword.other.machine.classicalb' ]
    it "should highlight the assignment operator completely (issue 6)", ->
      {tokens} = grammar.tokenizeLine 'xx:=iv'
      expect(tokens[0]).toEqual value: 'xx', scopes: [ 'source.classicalb', 'identifier.classicalb' ]
      expect(tokens[1]).toEqual value: ':=', scopes: [ 'source.classicalb', 'keyword.operator.assignment.classicalb' ]
      expect(tokens[2]).toEqual value: 'iv', scopes: [ 'source.classicalb', 'identifier.classicalb' ]
