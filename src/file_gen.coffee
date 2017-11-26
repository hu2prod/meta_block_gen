fs = require 'fs'
path = require 'path'
require 'shelljs/global'

module.exports = (col)->
  return if col.chk_file __FILE__
  # ###################################################################################################
  #    file_gen
  # ###################################################################################################
  bp = col.autogen 'file_gen', /^file_gen$/, (ret)->
    ret.hash.force_rewrite = false
    ret.flush_fn = ()->
      if !@hash.file?
        throw new Error "Can't compile #{@name}. No hash.file"
      if !@hash.cont?
        throw new Error "Can't compile #{@name}. No hash.cont"
      skip = false
      if exists = fs.existsSync @hash.file
        if @hash.cont == fs.readFileSync @hash.file, 'utf-8'
          puts "[SKIP   ] #{@hash.file} same content"
          skip = true
      if !skip or ret.hash.force_rewrite
        fs.writeFileSync @hash.file, @hash.cont
        if exists
          puts "[REWRITE] #{@hash.file}"
        else
          puts "[WRITE  ] #{@hash.file}"
      if @hash.executable
        chmod "+x", @hash.file
      return
    ret
  # ###################################################################################################
  #    template gen
  # ###################################################################################################
  bp = col.autogen 'template_gen', /^template_gen$/, (ret)->
    fg = col.gen 'file_gen'
    ret.flush_fn = ()->
      if !@hash.file?
        throw new Error "Can't compile #{@name}. No hash.file"
      if !@hash.cont?
        throw new Error "Can't compile #{@name}. No hash.cont"
      template = @hash.cont
      for k,v of @hash
        template = template.split("$#{k}$").join(v)
      
      fg.hash.file = @hash.file
      fg.hash.cont = template
      
      for child in @child_list
        child.flush()
      return
    ret
  # ###################################################################################################
  #    folder wrap
  # ###################################################################################################
  bp = col.autogen 'path_wrap', /^path_wrap$/, (ret)->
    ret.compile_fn = ()->
      if !@hash._injected
        throw new Error "Can't compile #{@name}. Must be injected"
      for child in @child_list
        child.compile()
      return
      
    ret.flush_fn = ()->
      if !@hash.path?
        throw new Error "Can't compile #{@name}. No hash.path"
      mkdir '-p', @hash.path
      
      _path = @hash.path
      walk = (root)->
        for child in root.child_list
          if child.hash.file?
            child.hash.file = path.join _path, child.hash.file
          if child.hash.path?
            child.hash.path = path.join _path, child.hash.path
            continue # do not update inner
          walk child
        return
      walk @
      
      for child in @child_list
        child.flush()
      return
    ret
  
  return
