fs = require 'fs'
path = require 'path'
require 'shelljs/global'

module.exports = (col)->
  return if col.chk_file __FILE__
  # ###################################################################################################
  #    file_op
  # ###################################################################################################
  bp = col.autogen 'file_op', (ret)->
    ret.flush_fn = ()->
      if !@hash.file?
        throw new Error "Can't compile #{@name}. No hash.file"
      if !@hash.cont?
        throw new Error "Can't compile #{@name}. No hash.cont"
      line_list = @hash.cont.split /\n/g
      for line in line_list
        line = line.replace /\$FILE\$/g, @hash.file
        puts line
        exec line
      
      return
    ret
  return
