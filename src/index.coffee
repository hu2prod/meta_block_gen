require 'fy'
require 'fy/experimental'

module.exports = (build_opt={})->
  mod = {}
  
  build_opt.block_mixin_list ?= []
  build_opt.block_mixin_constructor_list ?= []
  # ###################################################################################################
  #    gen wrap
  # ###################################################################################################
  mod._block_stack = []

  mod._gen_start = (block)->
    last_block = block
    if parent = mod._block_stack.last()
      block.parent_block = parent
      parent.child_list.upush block
    
    mod._block_stack.push block
    return

  mod._gen_end = (block)->
    last_block = block
    if mod._block_stack.last() != block
      ### !pragma coverage-skip-block ###
      throw new Error "gen_end violation"
    mod._block_stack.pop()
    return
  # ###################################################################################################

  class mod.Block
    parent_block_blueprint: null
    parent_block          : null
    
    name      : '' # autogen full name
    param_hash: {} # parsed name
    hash      : {} # extra
    
    child_list: [] # for nested Blocks
    body_list : [] # for code
    require_endpoint_hash : {}
    
    for mixin in build_opt.block_mixin_list
      mixin @
    constructor:()->
      for mixin in build_opt.block_mixin_constructor_list
        mixin @
      @param_hash = {}
      @hash       = {}
      
      @child_list = []
      @body_list  = []
      
      @require_endpoint_hash = {}
    
    debug_name : ()->
      "#{@name}@#{@parent_block_blueprint.name}"
    
    # may be replaceable
    require_fn : ()->
      col = @parent_block_blueprint.parent_collection
      
      need_more = true
      while need_more
        need_more = false
        present_hash = {}
        for child in @child_list
          child.require_phase(false)
          present_hash[child.name] = true
        
        require_list = []
        for child in @child_list
          for endpoint, list of child.require_endpoint_hash
            if endpoint in ['parent', @name]
              require_list.uappend list
            else
              @require_endpoint_hash[endpoint] ?= []
              @require_endpoint_hash[endpoint].uappend list
        
        for module in require_list
          continue if present_hash[module]
          need_more = true
          @inject ()->
            col.gen module
    
      return
    
    require : (name, endpoint = 'parent')->
      @require_endpoint_hash[endpoint] ?= []
      @require_endpoint_hash[endpoint].upush name
      return
    
    require_phase : (is_root = true)->
      @require_fn.call @
      if is_root
        for endpoint, list of @require_endpoint_hash
          perr "WARNING unresolved endpoint #{endpoint} #{JSON.stringify list}"
      return
    
    # replaceable
    compile_fn : ()->
      if @hash._injected
        throw new Error "this block (#{@debug_name()}) is not designed to be injected"
      for child in @child_list
        child.compile()
      
      return
    
    compile : ()->
      @compile_fn.call @
      return
    
    # replaceable
    flush_fn : ()->
      for child in @child_list
        child.flush()
      return
    
    flush : ()->
      @flush_fn.call @
      return
    
    inject : (fn)->
      @hash._injected = true # сигнализирует gen'у, что список детей поменяли
      mod._gen_start @
      fn()
      mod._gen_end @
      return
  
  # ###################################################################################################
  class mod.Block_blueprint
    parent_collection : null
    name : ''
    regex: null
    param_hash : {}
    
    constructor:()->
      @param_hash = {}
    
    # replaceable
    name_validator : (name)->'' # error string
    
    generator : (ret)-># replaceable
    
    generator2 : (name)->
      ()=>
        ret = new mod.Block
        ret.name = name
        mod._gen_start ret
        list = @regex.exec name
        idx = 1
        for k,type of @param_hash
          val = list[idx++]
          val = +val if type == 'int'
          ret.param_hash[k] = val
        ret.parent_block_blueprint = @
        
        @generator.call @, ret
        mod._gen_end ret
        ret
  
  # ###################################################################################################
  class mod.Block_blueprint_collection
    file_cache    : {}
    cache_hash    : {}
    generator_list: []
    param_hash    : {} # will be applied to next autogen
    constructor:()->
      @file_cache     = {}
      @cache_hash     = {}
      @generator_list = []
      @param_hash     = {}
    
    chk_file : (file)->
      return true if @file_cache[file]
      @file_cache[file] = true
      false
    
    gen : (name)->
      return ret() if ret = @cache_hash[name]
      
      pass_list = []
      err = ''
      for v in @generator_list
        continue if !v.regex.test name
        err = v.name_validator name
        continue if '' != err
        pass_list.push v
      if pass_list.length > 1
        throw new Error "multiple generators called on name '#{name}'"
      if pass_list.length == 0
        throw new Error "no generators called on name '#{name}' err='#{err}'"
      generator = pass_list[0]
      
      ret = @cache_hash[name] = generator.generator2(name)
      ret()
    
    autogen : (name, regex, fn)->
      if !fn
        fn = regex
        regex = new RegExp "^#{name}$"
      @generator_list.push bp = new mod.Block_blueprint
      bp.parent_collection = @
      bp.name  = name
      bp.regex = regex
      bp.generator = fn
      bp.param_hash = @param_hash
      @param_hash = {}
      
      bp
  
  mod