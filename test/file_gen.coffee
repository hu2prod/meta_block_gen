assert = require 'assert'

mod = require('../src/index.coffee')()
col = new mod.Block_blueprint_collection
require('../src/file_gen.coffee')(col)
require('../src/file_gen.coffee')(col) # chk_file
fs = require 'fs'

describe 'file_gen section', ()->
  it 'test init', ()->
    rm '-rf', 'tmp'
    mkdir 'tmp'
  
  describe 'file_gen', ()->
    it 'with default_options_ok', ()->
      fg = col.gen 'file_gen'
      fg.hash.file = 'tmp/file.coffee'
      fg.hash.cont = "hello_world"
      
      fg.compile()
      fg.flush()
      
      assert fs.existsSync fg.hash.file
      assert.equal fs.readFileSync(fg.hash.file, 'utf-8'), fg.hash.cont
      rm fg.hash.file
    
    describe 'throws', ()->
      it 'no file', ()->
        fg = col.gen 'file_gen'
        # fg.hash.file = 'tmp/file.coffee'
        fg.hash.cont = "hello_world"
        
        fg.compile()
        assert.throws ()-> fg.flush()
      
      it 'no cont', ()->
        fg = col.gen 'file_gen'
        fg.hash.file = 'tmp/file.coffee'
        # fg.hash.cont = "hello_world"
        
        fg.compile()
        assert.throws ()-> fg.flush()
  
  describe 'template_gen', ()->
    it 'with default_options_ok', ()->
      fg = col.gen 'template_gen'
      fg.hash.file = 'tmp/file.coffee'
      fg.hash.cont = "hello_world $tmpl_var$"
      fg.hash.tmpl_var = 1
      
      fg.compile()
      fg.flush()
      
      assert fs.existsSync fg.hash.file
      assert.equal fs.readFileSync(fg.hash.file, 'utf-8'), "hello_world 1"
      rm fg.hash.file
    
    describe 'throws', ()->
      it 'no file', ()->
        fg = col.gen 'template_gen'
        # fg.hash.file = 'tmp/file.coffee'
        fg.hash.cont = "hello_world"
        
        fg.compile()
        assert.throws ()-> fg.flush()
      
      it 'no cont', ()->
        fg = col.gen 'template_gen'
        fg.hash.file = 'tmp/file.coffee'
        # fg.hash.cont = "hello_world"
        
        fg.compile()
        assert.throws ()-> fg.flush()
  
  describe 'path_wrap', ()->
    it 'with default_options_ok', ()->
      pw = col.gen 'path_wrap'
      pw.hash.path = 'tmp/test'
      pw.inject ()->
        fg = col.gen 'file_gen'
        fg.hash.file = 'file.coffee'
        fg.hash.cont = "hello_world"
        return
      
      pw.compile()
      pw.flush()
      file = "tmp/test/file.coffee"
      
      assert fs.existsSync file
      assert.equal fs.readFileSync(file, 'utf-8'), "hello_world"
      rm file
    
    it 'nested', ()->
      pw = col.gen 'path_wrap'
      pw.hash.path = 'tmp'
      pw.inject ()->
        pw2 = col.gen 'path_wrap'
        pw2.hash.path = 'test'
        pw2.inject ()->
          fg = col.gen 'file_gen'
          fg.hash.file = 'file.coffee'
          fg.hash.cont = "hello_world"
          return
      
      pw.compile()
      pw.flush()
      file = "tmp/test/file.coffee"
      
      assert fs.existsSync file
      assert.equal fs.readFileSync(file, 'utf-8'), "hello_world"
    
    it 'skip other blocks', ()->
      pw = col.gen 'path_wrap'
      col.autogen 'test', /^test$/, (ret)->ret
      pw.hash.path = 'tmp/test'
      pw.inject ()->
        fg = col.gen 'file_gen'
        fg.hash.file = 'file.coffee'
        fg.hash.cont = "hello_world"
        col.gen 'test'
        return
      
      pw.compile()
      pw.flush()
      file = "tmp/test/file.coffee"
      
      assert fs.existsSync file
      assert.equal fs.readFileSync(file, 'utf-8'), "hello_world"
    
    describe 'throws', ()->
      it 'no inject', ()->
        pw = col.gen 'path_wrap'
        pw.hash.path = 'tmp/test'
        
        assert.throws ()-> pw.compile()
      
      it 'no path', ()->
        pw = col.gen 'path_wrap'
        # pw.hash.path = 'tmp/test'
        pw.inject ()->
          fg = col.gen 'file_gen'
          fg.hash.file = 'file.coffee'
          fg.hash.cont = "hello_world"
          return
        
        pw.compile()
        assert.throws ()-> pw.flush()
  
  describe 'tmp describe', ()->
    it 'test final', ()->
      rm '-rf', 'tmp'