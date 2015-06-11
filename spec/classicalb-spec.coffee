describe 'Classical B grammar', ->
  grammar = null

  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage('language-b-event-b')

    runs ->
      grammar = atom.grammars.grammarForScopeName('source.classicalb')

  it 'parses the grammar', ->
    expect(grammar).toBeTruthy()
    expect(grammar.scopeName).toBe 'source.classicalb'

  describe "comments", ->
    it "tokenizes an empty block comment", ->
      {tokens} = grammar.tokenizeLine '/**/'
      expect(tokens[0]).toEqual value: '/*', scopes: [ 'source.classicalb', 'comment.block.classicalb', 'punctuation.definition.comment.classicalb' ]
