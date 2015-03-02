###
# Atom uses the Jasmine JavaScript testing framework.
# More information here: http://jasmine.github.io/
#
# To directly run the tests in this directory from Atom, press `cmd-alt-ctrl-p`.
#
# For more information:
#   - https://atom.io/docs/latest/creating-a-package#writing-tests
#   - https://atom.io/docs/latest/creating-a-package#running-tests
###

'use strict'

PairProgramming = require '../lib/pair-programming'

describe 'PairProgramming', ->
  describe 'A suite', ->
    it 'should spec with an expectation', ->
      expect(PairProgramming).not.toBeNull()
