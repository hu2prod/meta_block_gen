assert = require 'assert'

mod = require('../src/index.coffee')()
col = new mod.Block_blueprint_collection
require('../src/coffee_gen.coffee')(col)
require('../src/coffee_gen.coffee')(col) # chk_file
fs = require 'fs'

describe 'coffee_gen section', ()->
  it 'test init', ()->
    rm '-rf', 'tmp'
    mkdir 'tmp'
  
  describe 'coffee_gen', ()->
    it 'with default_options_ok', ()->
      fg = col.gen 'coffee_gen'
      fg.hash.file = 'tmp/file.coffee'
      fg.inject ()->
        c = col.gen 'raw_code'
        c.hash.code = "console.log 'Hello World'"
      
      fg.compile()
      fg.flush()
      
      assert fs.existsSync fg.hash.file
      assert.equal fs.readFileSync(fg.hash.file, 'utf-8'), """
      #!/usr/bin/env iced
      # Scope raw_code
      console.log 'Hello World'
      # END Scope raw_code
      
      """
      rm fg.hash.file
    
    describe 'throws', ()->
  
  describe 'tmp describe', ()->
    it 'test final', ()->
      rm '-rf', 'tmp'