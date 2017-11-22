module = @
class @Zone
  parent    : null
  scope     : ''
  code_list : []
  child_list: []
  skip_pass_up : false
  constructor:(@scope)->
    @code_list  = []
    @child_list = []
  
  get_parent : ()->
    return @ if !@parent
    @parent.get_parent()
  
  code : (t)->
    @code_list.push t
  
  append : (t_zone)->
    return if t_zone.skip_pass_up
    # TOO useful for module dev
    unless t_zone instanceof module.Zone
      p t_zone
      throw new Error "arg check fail #{t_zone.constructor.name} != Zone"
    @child_list.push t_zone
    t_zone.parent = @
    return
  
  gen : ()->
    ret = []
    if @code_list.length
      ret.push "# Scope #{@scope}"
      for v in @code_list
        if typeof v == 'function'
          ret.push v()
        else
          ret.push v
      ret.push "# END Scope #{@scope}"
      ret.push ""
    for child in @child_list
      if code = child.gen()
        ret.push code
    
    """
    #{ret.join('\n')}
    """
  
class @Zone_holder
  parent: null
  scope : ''
  delayed_list : []
  hash  : {}
  actualized : false
  constructor:(@scope)->
    @delayed_list = []
    @hash = {}
  
  get_parent : ()->
    return @ if !@parent
    @parent.get_parent()
  
  append : (zh)->
    unless zh instanceof module.Zone_holder
      p zh
      throw new Error "arg check fail #{zh.constructor.name} != Zone_holder"
    zh.parent = @
    @delayed_list.push zh
    return
  
  actualize : ()->
    return if @actualized
    @actualized = true
    for zh in @delayed_list
      zh.actualize()
      for k,v of zh.hash
        if !z = @hash[k]
          z = @hash[k] = new module.Zone @scope
        z.append v
    return
  
