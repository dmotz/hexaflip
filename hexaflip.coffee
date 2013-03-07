# hexaFlip
# 0.0.1
# Dan Motzenbecker
# http://oxism.com
# Copyright 2013, MIT License

baseName = 'hexaFlip'
className = baseName[0].toUpperCase() + baseName.slice 1
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
  size: 200
  margin: 10
  fontSize: 132
  perspective: 1000
  touchSensitivity: 1

cssClass = baseName.toLowerCase()
faceNames = ['front', 'bottom', 'back', 'top', 'left', 'right']
faceSequence = faceNames.slice 0, 4
urlRx = /^((((https?)|(file)):)?\/\/)|(data:)|(\.\.?\/)/i

class window.HexaFlip

  constructor: (@el, @sets, @options = {}) ->
    return unless css.transform and @el
    @[option] = @options[option] ? defaults[option] for option, value of defaults
    @fontSize += 'px' if typeof @fontSize is 'number'

    unless @sets
      @el.classList.add cssClass + '-timepicker'
      @sets =
        hour: (i + '' for i in [1..12])
        minute: (i + '0' for i in [0..5])
        meridian: ['am', 'pm']

    setsKeys = Object.keys @sets
    setsLength = setsKeys.length
    cubeFragment = document.createDocumentFragment()
    i = z = 0
    midPoint = setsLength / 2 + 1
    @cubes = {}
    for key, set of @sets
      cube = @cubes[key] = @_createCube key
      if ++i < midPoint
        z++
      else
        z--
      cube.el.style.zIndex = z
      @_setContent cube.front, set[0]
      cubeFragment.appendChild cube.el
      for val in set
        if urlRx.test val
          image = new Image
          image.src = val

    @cubes[setsKeys[0]].el.style.marginLeft = '0'
    @cubes[setsKeys[setsKeys.length - 1]].el.style.marginRight = '0'

    @el.classList.add cssClass
    @el.style.height = @size + 'px'
    @el.style.width = ((@size + @margin * 2) * setsLength) - @margin * 2 + 'px'
    @el.style[css.perspective] = @perspective + 'px'
    @el.appendChild cubeFragment


  _createCube: (set) ->
    cube =
      set: set
      offset: 0
      y1: 0
      yDelta: 0
      yLast: 0
      el: document.createElement 'div'

    cube.el.className = "#{ cssClass }-cube #{ cssClass }-cube-#{ set }"
    cube.el.style.margin = "0 #{ @margin }px"
    cube.el.style.width = cube.el.style.height = @size + 'px'
    cube.el.style[css.transform] = @_getTransform 0

    for side in faceNames
      cube[side] = document.createElement 'div'
      cube[side].className = cssClass + '-' + side
      rotate3d = do ->
        switch side
          when 'front'
            '0, 0, 0, 0deg'
          when 'back'
            '1, 0, 0, 180deg'
          when 'top'
            '1, 0, 0, 90deg'
          when 'bottom'
            '1, 0, 0, -90deg'
          when 'left'
            '0, 1, 0, -90deg'
          when 'right'
            '0, 1, 0, 90deg'

      cube[side].style[css.transform] = "rotate3d(#{ rotate3d }) translate3d(0, 0, #{ @size / 2 }px)"
      cube[side].style.fontSize = @fontSize
      cube.el.appendChild cube[side]

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
    "translateZ(-#{ @size / 2 }px) rotateX(#{ deg }deg)"


  _setContent: (el, content) ->
    return unless el and content
    if typeof content is 'object'
      {style, value} = content
      el.style[key] = val for key, val of style
    else
      value = content

    if urlRx.test value
      el.innerHTML = ''
      el.style.backgroundImage = "url(#{ value })"
    else
      el.innerHTML = value


  _setSides: (cube) ->
    cube.el.style[css.transform] = @_getTransform cube.yDelta
    cube.offset = offset = Math.floor cube.yDelta / 90
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

    setOffset %= setLength if setOffset >= setLength
    faceOffset %= 4 if faceOffset >= 4
    topAdj = faceOffset - 1
    bottomAdj = faceOffset + 1
    topAdj = 3 if topAdj is -1
    bottomAdj = 0 if bottomAdj is 4
    @_setContent cube[faceSequence[topAdj]], set[setOffset - 1] or set[setLength - 1]
    @_setContent cube[faceSequence[bottomAdj]], set[setOffset + 1] or set[0]


  _onTouchStart: (e, cube) ->
    e.preventDefault()
    cube.touchStarted = true
    e.currentTarget.classList.add 'no-tween'
    if e.type is 'mousedown'
      cube.y1 = e.pageY
    else
      cube.y1 = e.touches[0].pageY


  _onTouchMove: (e, cube) ->
    return unless cube.touchStarted
    e.preventDefault()
    cube.diff = (e.pageY - cube.y1) * @touchSensitivity
    cube.yDelta = cube.yLast - cube.diff
    @_setSides cube


  _onTouchEnd: (e, cube) ->
    cube.touchStarted = false
    mod = cube.yDelta % 90
    if mod < 45
      cube.yLast = cube.yDelta + mod
    else
      if cube.yDelta > 0
        cube.yLast = cube.yDelta + mod
      else
        cube.yLast = cube.yDelta - (90 - mod)

    if cube.yLast % 90 isnt 0
      cube.yLast -= cube.yLast % 90

    cube.el.classList.remove 'no-tween'
    cube.el.style[css.transform] = @_getTransform cube.yLast


  _onTouchLeave: (e, cube) ->
    return unless cube.touchStarted
    @_onTouchEnd e, cube


  _onMouseOut: (e, cube) =>
    return unless cube.touchStarted
    @_onTouchEnd e, cube if e.toElement and !cube.el.contains e.toElement


  setValue: (settings) ->
    for key, value of settings
      continue unless @sets[key] and !@cubes[key].touchStarted
      value = value.toString()
      cube = @cubes[key]
      index = @sets[key].indexOf value
      cube.yDelta = cube.yLast = 90 * index
      @_setSides cube
      @_setContent cube[faceSequence[index % 4]], value


  getValue: ->
    for set, cube of @cubes
      set = @sets[set]
      setLength = set.length
      offset = cube.yLast / 90
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


  flip: (back) ->
    delta = if back then -90 else 90
    for set, cube of @cubes
      continue if cube.touchStarted
      cube.yDelta = cube.yLast += delta
      @_setSides cube


  flipBack: ->
    @flip true


if window.jQuery? or window.$?.data?
  $.fn.hexaFlip = (sets, options) ->
    return @ unless css.transform
    if typeof sets is 'string'
      methodName = sets
      return @ unless typeof HexaFlip::[methodName] is 'function'
      for el in @
        return unless instance = $.data el, baseName
        args = Array::slice.call arguments
        args.shift()
        instance[methodName] args
      @
    else
      for el in @
        if instance = $.data el, baseName
          return instance
        else
          $.data el, baseName, new HexaFlip el, sets, options

