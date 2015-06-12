describe 'Classical B grammar', ->
  grammar = null

  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage('language-b-eventb')

    runs ->
      grammar = atom.grammars.grammarForScopeName('source.classicalb')

  it 'parses the grammar', ->
    expect(grammar).toBeTruthy()
    expect(grammar.scopeName).toBe 'source.classicalb'

  describe "literals", ->
    it "tokenizes integer literals", ->
      {tokens} = grammar.tokenizeLine "1 = 5"
      expect(tokens[0]).toEqual value: '1', scopes: [ 'source.classicalb', 'constant.numeric.classicalb' ]
      expect(tokens[2]).toEqual value: '=', scopes: [ 'source.classicalb', 'keyword.operator.assignment.classicalb' ]
      expect(tokens[4]).toEqual value: '5', scopes: [ 'source.classicalb', 'constant.numeric.classicalb' ]

  describe "operators", ->
    it "detects or correctly", ->
      {tokens} = grammar.tokenizeLine "orb"
      expect(tokens[0]).toEqual value: 'orb', scopes: [ 'source.classicalb', 'identifier.classicalb' ]

      {tokens} = grammar.tokenizeLine "aor"
      expect(tokens[0]).toEqual value: 'aor', scopes: [ 'source.classicalb', 'identifier.classicalb' ]

      {tokens} = grammar.tokenizeLine "aorb"
      expect(tokens[0]).toEqual value: 'aorb', scopes: [ 'source.classicalb', 'identifier.classicalb' ]

      {tokens} = grammar.tokenizeLine "a or b"
      expect(tokens[0]).toEqual value: 'a', scopes: [ 'source.classicalb', 'identifier.classicalb' ]
      expect(tokens[2]).toEqual value: 'or', scopes: [ 'source.classicalb', 'keyword.operator.logical.classicalb' ]
      expect(tokens[4]).toEqual value: 'b', scopes: [ 'source.classicalb', 'identifier.classicalb' ]

  describe "comments", ->
    it "tokenizes an empty block comment", ->
      {tokens} = grammar.tokenizeLine '/**/'
      expect(tokens[0]).toEqual value: '/*', scopes: [ 'source.classicalb', 'comment.block.classicalb', 'punctuation.definition.comment.classicalb' ]
      expect(tokens[1]).toEqual value: '*/', scopes: [ 'source.classicalb', 'comment.block.classicalb', 'punctuation.definition.comment.classicalb' ]
    it "tokenizes a block comment", ->
      {tokens} = grammar.tokenizeLine '/* this is my comment */'
      expect(tokens[0]).toEqual value: '/*', scopes: [ 'source.classicalb', 'comment.block.classicalb', 'punctuation.definition.comment.classicalb' ]
      expect(tokens[1]).toEqual value: ' this is my comment ', scopes: [ 'source.classicalb', 'comment.block.classicalb' ]
      expect(tokens[2]).toEqual value: '*/', scopes: [ 'source.classicalb', 'comment.block.classicalb', 'punctuation.definition.comment.classicalb' ]

  describe "simple clause", ->
    it "tokenizes a simple machine clause including an operator", ->
      {tokens} = grammar.tokenizeLine 'INVARIANT access : USER <-> PRINTER'
      expect(tokens[0]).toEqual value: 'INVARIANT', scopes: [ 'source.classicalb', 'keyword.other.machineclause.classicalb' ]
      expect(tokens[2]).toEqual value: 'access', scopes: [ 'source.classicalb', 'identifier.classicalb' ]
      expect(tokens[4]).toEqual value: ':', scopes: [ 'source.classicalb', 'keyword.operator.set.classicalb' ]
      expect(tokens[6]).toEqual value: 'USER', scopes: [ 'source.classicalb', 'identifier.classicalb' ]
      expect(tokens[8]).toEqual value: '<->', scopes: [ 'source.classicalb', 'keyword.operator.relation.classicalb' ]
      expect(tokens[10]).toEqual value: 'PRINTER', scopes: [ 'source.classicalb', 'identifier.classicalb' ]
