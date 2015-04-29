# HexaFlip
# 0.1.6
# Dan Motzenbecker
# http://oxism.com
# Copyright 2013, MIT License

baseName   = 'hexaFlip'
className  = baseName[0].toUpperCase() + baseName[1...]
prefixList = ['webkit', 'Moz', 'O', 'ms']

prefixProp = (prop) ->
  return prop.toLowerCase() if document.body.style[prop.toLowerCase()]?
  for prefix in prefixList
    prefixed = prefix + prop
    return prefixed if document.body.style[prefixed]?
  false

css = {}
css[prop.toLowerCase()] = prefixProp prop for prop in ['Transform', 'Perspective']

defaults =
  size:             200
  margin:           10
  fontSize:         132
  perspective:      1000
  touchSensitivity: 1
  horizontalFlip:   false
  domEvents:        null

cssClass     = baseName.toLowerCase()
faceNames    = ['front', 'bottom', 'back', 'top', 'left', 'right']
faceSequence = faceNames[...4]
urlRx        = /(^(?:(?:(?:(?:https?)|(?:file)):)?\/\/)|^(?:data:)|^(?:(?:\.\.?)?\/))(?:.+)/i

class HexaFlip

  constructor: (@el, @sets, @options = {}) ->
    return unless css.transform and @el
    return new HexaFlip arguments... unless @ instanceof HexaFlip
    @el = document.querySelector @el if typeof @el is 'string'
    @[option] = @options[option] ? defaults[option] for option, value of defaults
    @fontSize += 'px' if typeof @fontSize is 'number'

    unless @sets
      @el.classList.add cssClass + '-timepicker'
      @sets =
        hour:     (i + '' for i in [1..12])
        minute:   (i + '0' for i in [0..5])
        meridian: ['am', 'pm']

    setsKeys     = Object.keys @sets
    setsLength   = setsKeys.length
    cubeFragment = document.createDocumentFragment()
    i = z = 0
    midPoint = setsLength / 2 + 1
    @cubes   = {}
    for key, set of @sets
      cube = @cubes[key] = @_createCube key
      if ++i < midPoint
        z++
      else
        z--
      cube.el.style.zIndex = z
      @_setContent cube.front, set[0]
      cubeFragment.appendChild cube.el
      (new Image).src = val for val in set when urlRx.test val

    @cubes[setsKeys[0]].el.style.marginLeft = '0'
    @cubes[setsKeys[setsKeys.length - 1]].el.style.marginRight = '0'

    @el.classList.add cssClass
    @el.style.height = @size + 'px'
    @el.style.width  = ((@size + @margin * 2) * setsLength) - @margin * 2 + 'px'
    @el.style[css.perspective] = @perspective + 'px'
    @el.appendChild cubeFragment
    @eProp = if @horizontalFlip then 'pageX' else 'pageY'

    if @domEvents
      for type, fn of @domEvents then do (fn) =>
        @el.addEventListener type, (e) =>
          {target} = e
          if target.classList.contains "#{ cssClass }-side"
            fn.call @, e, target, target.parentNode.parentNode
        , false

      @domEvents = null


  _createCube: (set) ->
    cube =
      set:    set
      offset: 0
      start:  0
      delta:  0
      last:   0
      el:     document.createElement 'div'
      holder: document.createElement 'div'

    cube.el.className    = "#{ cssClass }-cube #{ cssClass }-cube-#{ set }"
    cube.el.style.margin = "0 #{ @margin }px"
    cube.el.style.width  = cube.el.style.height = \
    cube.holder.style.width = cube.holder.style.height = @size + 'px'
    cube.holder.style[css.transform] = @_getTransform 0
    sideProto = document.createElement 'div'
    sideProto.classList.add cssClass + '-side'

    for side in faceNames
      cube[side] = sideProto.cloneNode false
      cube[side].classList.add "#{ cssClass }-side-#{ side }"
      rotation =
        switch side
          when 'front'
            ''
          when 'back'
            'rotateX(180deg)'
          when 'top'
            'rotateX(90deg)'
          when 'bottom'
            'rotateX(-90deg)'
          when 'left'
            'rotateY(-90deg)'
          when 'right'
            'rotateY(90deg)'

      cube[side].style[css.transform] = "#{ rotation } translate3d(0, 0, #{ @size / 2 }px)" +
        (if @horizontalFlip then 'rotateZ(90deg)' else '')
      cube[side].style.fontSize = @fontSize
      cube.holder.appendChild cube[side]

    cube.el.appendChild cube.holder

    eventPairs = [['TouchStart', 'MouseDown'], ['TouchMove', 'MouseMove'],
      ['TouchEnd', 'MouseUp'], ['TouchLeave', 'MouseLeave']]
    mouseLeaveSupport = 'onmouseleave' of window

    for eventPair in eventPairs
      for eString in eventPair then do (fn = '_on' + eventPair[0], cube) =>
        unless (eString is 'TouchLeave' or eString is 'MouseLeave') and !mouseLeaveSupport
          cube.el.addEventListener eString.toLowerCase(), ((e) => @[fn] e, cube), true
        else
          cube.el.addEventListener 'mouseout', ((e) => @_onMouseOut e, cube), true

    @_setSides cube
    cube


  _getTransform: (deg) ->
    (if @horizontalFlip then 'rotateZ(-90deg)' else '') +
      " translateZ(-#{ @size / 2 }px) rotateX(#{ deg }deg)"


  _setContent: (el, content) ->
    return unless el and content
    if typeof content is 'object'
      {style, value} = content
      el.style[key]  = val for key, val of style
    else
      value = content

    if urlRx.test value
      el.innerHTML = ''
      el.style.backgroundImage = "url('#{ value }')"
    else
      el.style.backgroundImage = 'none'
      el.innerHTML = value


  _setSides: (cube) ->
    cube.holder.style[css.transform] = @_getTransform cube.delta
    cube.offset = offset = Math.floor cube.delta / 90
    return if offset is cube.lastOffset
    cube.lastOffset = faceOffset = setOffset = offset
    set = @sets[cube.set]
    setLength = set.length
    if offset < 0
      faceOffset = setOffset = ++offset
      if offset < 0
        if -offset > setLength
          setOffset = setLength - -offset % setLength
          setOffset = 0 if setOffset is setLength
        else
          setOffset = setLength + offset

        if -offset > 4
          faceOffset = 4 - -offset % 4
          faceOffset = 0 if faceOffset is 4
        else
          faceOffset = 4 + offset

    setOffset  %= setLength if setOffset >= setLength
    faceOffset %= 4 if faceOffset >= 4
    topAdj      = faceOffset - 1
    bottomAdj   = faceOffset + 1
    topAdj      = 3 if topAdj is -1
    bottomAdj   = 0 if bottomAdj is 4
    @_setContent cube[faceSequence[topAdj]], set[setOffset - 1] or set[setLength - 1]
    @_setContent cube[faceSequence[bottomAdj]], set[setOffset + 1] or set[0]


  _onTouchStart: (e, cube) ->
    cube.touchStarted = true
    cube.holder.classList.add 'no-tween'
    if e.type is 'touchstart'
      cube.start = e.touches[0][@eProp]
    else
      cube.start = e[@eProp]


  _onTouchMove: (e, cube) ->
    return unless cube.touchStarted
    e.preventDefault()
    if e.type is 'touchmove'
      cube.diff = (e.touches[0][@eProp] - cube.start) * @touchSensitivity
    else
      cube.diff = (e[@eProp] - cube.start) * @touchSensitivity

    cube.delta = cube.last - cube.diff
    @_setSides cube


  _onTouchEnd: (e, cube) ->
    cube.touchStarted = false
    mod = cube.delta % 90
    if mod < 45
      cube.last = cube.delta + mod
    else
      if cube.delta > 0
        cube.last = cube.delta + mod
      else
        cube.last = cube.delta - (90 - mod)

    if cube.last % 90 isnt 0
      cube.last -= cube.last % 90

    cube.holder.classList.remove 'no-tween'
    cube.holder.style[css.transform] = @_getTransform cube.last


  _onTouchLeave: (e, cube) ->
    return unless cube.touchStarted
    @_onTouchEnd e, cube if e.toElement and !cube.el.contains e.toElement


  _onMouseOut: (e, cube) ->
    return unless cube.touchStarted
    @_onTouchEnd e, cube if e.toElement and !cube.el.contains e.toElement


  setValue: (settings) ->
    for key, value of settings
      continue unless @sets[key] and !@cubes[key].touchStarted
      value = value.toString()
      cube  = @cubes[key]
      index = @sets[key].indexOf value
      cube.delta = cube.last = 90 * index
      @_setSides cube
      @_setContent cube[faceSequence[index % 4]], value
    @


  getValue: ->
    for set, cube of @cubes
      set       = @sets[set]
      setLength = set.length
      offset    = cube.last / 90
      if offset < 0
        if -offset > setLength
          offset = setLength - -offset % setLength
          offset = 0 if offset is setLength
        else
          offset = setLength + offset

      offset %= setLength if offset >= setLength
      if typeof set[offset] is 'object'
        set[offset].value
      else
        set[offset]


  flipCube: (key, back) ->
    cube = @cubes[key]
    return if cube.touchStarted
    cube.delta = cube.last += if back then -90 else 90
    @_setSides cube
    @


  flipCubeBack: (key) ->
    @flipCube key, true


  flip: (back) ->
    @flipCube key, back for key of @cubes
    @


  flipBack: ->
    @flip true


if module?.exports
  module.exports = HexaFlip
else if define?.amd
  define -> HexaFlip
else
  window.HexaFlip = HexaFlip

return unless window? and ($ = window.jQuery or window.$) and $.data

$::hexaFlip = (sets, options) ->
  return @ unless css.transform
  if typeof sets is 'string'
    methodName = sets
    return @ unless typeof HexaFlip::[methodName] is 'function' and
      instance = $.data @[0], baseName

    args = Array::slice.call arguments
    args.shift()
    instance[methodName] args

  else
    for el in @
      continue if $.data el, baseName
      $.data el, baseName, new HexaFlip el, sets, options
    @

