assert = require 'assert'

mod = require '../src/index.coffee'

describe 'index section', ()->
  it 'with default_options_ok', ()->
    default_bg = mod()
    return
  
  describe 'default_constructor', ()->
    default_bg = mod()
    
    it 'Block', ()->
      new default_bg.Block
      return
    
    it 'Block_blueprint', ()->
      new default_bg.Block_blueprint
      return
    
    it 'Block_blueprint_collection', ()->
      new default_bg.Block_blueprint_collection
      return
    
    it 'Block_blueprint generator', ()->
      bp = new default_bg.Block_blueprint
      bp.regex = /^a$/
      bp.generator2()()
      return
  
  describe 'default_constructor collection', ()->
    default_bg = mod()
    
    it 'autogen', ()->
      col = new default_bg.Block_blueprint_collection
      col.autogen 'test', /^test$/, (ret)->
        ret
      col.gen 'test'
      return
    
    it 'autogen right select', ()->
      col = new default_bg.Block_blueprint_collection
      col.autogen 'test_wtf', /^test_wtf$/, (ret)->
        ret
      
      col.autogen 'test', /^test$/, (ret)->
        ret
      col.gen 'test'
      return
    
    it 'autogen right select validator', ()->
      col = new default_bg.Block_blueprint_collection
      ag_block = col.autogen 'test_wtf', /^test*$/, (ret)->
        ret
      ag_block.name_validator = ()->'some reject reason'
      
      col.autogen 'test', /^test$/, (ret)->
        ret
      col.gen 'test'
      return
    
    it 'autogen regex_test', ()->
      col = new default_bg.Block_blueprint_collection
      col.param_hash =
        a : 'int'
      col.autogen 'test', /^test_(\d+)$/, (ret)->
        ret
      bl1 = col.gen 'test_1'
      assert.equal bl1.param_hash.a, 1
      return
    
    it 'autogen regex_test_string', ()->
      col = new default_bg.Block_blueprint_collection
      col.param_hash =
        a : 'str'
      col.autogen 'test', /^test_(\d+)$/, (ret)->
        ret
      bl1 = col.gen 'test_1'
      assert.equal bl1.param_hash.a, '1'
      return
    
    it 'compile empty', ()->
      col = new default_bg.Block_blueprint_collection
      col.autogen 'test', /^test$/, (ret)->
        ret
      bl1 = col.gen 'test'
      bl1.compile()
      return
    
    it 'flush empty', ()->
      col = new default_bg.Block_blueprint_collection
      counter = 0
      col.autogen 'test', /^test$/, (ret)->
        counter++
        ret
      bl1 = col.gen 'test'
      bl1.compile()
      bl1.flush()
      assert.equal counter, 1
      return
    
    it 'default_child', ()->
      col = new default_bg.Block_blueprint_collection
      counter = 0
      col.autogen 'test', /^test$/, (ret)->
        col.gen 'child'
        ret
      col.autogen 'child', /^child$/, (ret)->
        counter++
        ret
      bl1 = col.gen 'test'
      bl1.compile()
      assert.equal counter, 1
      return
    
    describe 'inject', ()->
      it 'inject', ()->
        col = new default_bg.Block_blueprint_collection
        col.autogen 'test', /^test$/, (ret)->
          ret
        bl1 = col.gen 'test'
        bl1.inject ()->
          col.gen 'test'
        
        assert.equal bl1.child_list.length, 1
        return
      
      it 'compile injected', ()->
        col = new default_bg.Block_blueprint_collection
        bp = col.autogen 'test', /^test$/, (ret)->
          ret.compile_fn = ()->
            for child in @child_list
              child.compile()
            return
          ret
          
        bl1 = col.gen 'test'
        bl1.inject ()->
          col.gen 'test'
        bl1.compile()
        bl1.flush()
        return
    
      describe 'throws', ()->
        it 'compile injected (not designed)', ()->
          col = new default_bg.Block_blueprint_collection
          col.autogen 'test', /^test$/, (ret)->
            ret
          bl1 = col.gen 'test'
          bl1.inject ()->
            col.gen 'test'
          assert.throws ()-> bl1.compile()
          return
    
    
    describe 'throws', ()->
      it 'no such block', ()->
        col = new default_bg.Block_blueprint_collection
        assert.throws ()-> col.gen 'wtf'
        return
      
      it '2 block', ()->
        col = new default_bg.Block_blueprint_collection
        col.autogen 'test', /^test$/, (ret)->
          ret
        col.autogen 'test', /^test$/, (ret)->
          ret
        assert.throws ()-> col.gen 'test'
        return
    
  describe 'lib example', ()->
    default_bg = mod()
    
    it 'ext_module test', ()->
      col = new default_bg.Block_blueprint_collection
      ext_module = ()->
        return if col.chk_file __FILE__
        col.autogen 'test', /^test$/, (ret)->
          ret.compile_fn = ()->
            ret.body_list.push "hello"
          ret
      
      ext_module()
      ext_module()
      
      bl1 = col.gen 'test'
      bl1.compile()
      assert.equal bl1.body_list.length, 1
    
      
    
  # TODO block_mixin_list test