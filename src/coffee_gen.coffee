fs = require 'fs'
path = require 'path'
{
  Zone_holder
  Zone
} = require './zone'

module.exports = (col)->
  return if col.chk_file __FILE__
  require('./file_gen')(col)
  # ###################################################################################################
  #    coffee_gen
  # ###################################################################################################
  bp = col.autogen 'sample_coffee_gen', (ret)->
    zh = ret.zh = new Zone_holder
    zg = zh.hash.zg = new Zone ret.name
    ret.compile_fn = ()->
      if !@hash._injected
        throw new Error "Can't compile #{@name}. Must be injected"
      if !@hash.file?
        throw new Error "Can't compile #{@name}. No hash.file"
      
      # ###################################################################################################
      #    zone joiner
      # ###################################################################################################
      for v in @child_list
        v.compile()
      
      for v in @child_list
        zh.append v.zh if v.zh
      
      zh.actualize()
      # ###################################################################################################
      @inject ()=>
        file = col.gen 'file_gen'
        file.hash.file = @hash.file
        file.hash.executable = true
        file.hash.cont = """
          #!/usr/bin/env iced
          #{zg.gen()}
          """
      
      return
    ret
  # ###################################################################################################
  #    raw_code
  # ###################################################################################################
  bp = col.autogen 'sample_raw_code', (ret)->
    zh = ret.zh = new Zone_holder
    zg = zh.hash.zg = new Zone ret.name
    ret.compile_fn = ()->
      if @hash._injected
        throw new Error "Can't compile #{@name}. Must be not injected"
      if !@hash.code?
        throw new Error "Can't compile #{@name}. No hash.code"
      zg.code @hash.code
      return
    ret
  return
