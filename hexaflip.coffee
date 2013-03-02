# hexaFlip
# 0.0.1
# Dan Motzenbecker
# http://oxism.com
# Copyright 2013, MIT License

baseName = 'hexaflip'
className = baseName[0].toUpperCase() + baseName.slice 1
testEl = document.createElement 'div'
prefixList = ['Webkit', 'Moz', 'O', 'ms']

prefixProp = (prop) ->
  return prop.toLowerCase() if testEl.style.transform?
  for prefix in prefixList
    prefixed = prefix + prop
    return prefixed if testEl.style[prefixed]?
  false

css =
  transform: prefixProp 'Transform'
  perspective: prefixProp 'Perspective'


defaults =
  size: 280
  margin: 10
  perspective: 1000


class window.Hexaflip

  className: baseName
  _touchCoefficient: .7
  _urlRx: /^((https?:)?\/\/)|(data:)/
  _faceNames: ['front', 'bottom', 'back', 'top', 'left', 'right']
  _faceSequence: @::_faceNames.slice 0, 4

  constructor: (@el, @sets, @options = {}) ->
    unless css.transform
      console?.warn "#{ baseName }: CSS transforms are not supported in this browser."
      return

    @_cubes = {}
    @[option] = @options[option] ? defaults[option] for option, value of defaults

    unless @sets
      @sets =
        hour: (i + '' for i in [1..12])
        minute: (i + '0' for i in [0..5])
        meridian: ['am', 'pm']

    cubeFragment = document.createDocumentFragment()

    for key, set of @sets
      @_cubes[key] = @_createCube key
      @_setContent @_cubes[key].front, set[0]
      cubeFragment.appendChild @_cubes[key].el
      for val in set
        if @_urlRx.test val
          image = new Image
          image.src = val

    setsKeys = Object.keys @sets
    setsLength = setsKeys.length
    @_cubes[setsKeys[0]].el.style.marginLeft = '0'
    @_cubes[setsKeys[setsKeys.length - 1]].el.style.marginRight = '0'

    @el.classList.add @className
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

    cube.el.className = "#{ @className }-cube #{ @className }-cube-#{ set }"
    cube.el.style.margin = "0 #{ @margin }px"
    cube.el.style.width = cube.el.style.height = @size + 'px'

    for side in @_faceNames
      cube[side] = document.createElement 'div'
      cube[side].className = @className + '-' + side
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
      cube.el.appendChild cube[side]

    eventPairs = [['TouchStart', 'MouseDown'], ['TouchMove', 'MouseMove'],
      ['TouchEnd', 'MouseUp'], ['TouchLeave', 'MouseOut']]

    for eventPair in eventPairs
      for eString in eventPair then do (fn = '_on' + eventPair[0], cube) =>
        cube.el.addEventListener eString.toLowerCase(), (e) =>
          @[fn] e, cube
        , true

    cube


  setValue: (settings) ->
    for key, value of settings
      value = value.toString()
      cube = @_cubes[key]
      index = @sets[key].indexOf value
      cube.yDelta = cube.yLast = 90 * index
      @_setSides cube
      @_setContent cube[@_faceSequence[index % 4]], value


  getValue: ->
    for set, cube of @_cubes
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
      set[offset]


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
    @_setContent cube[@_faceSequence[topAdj]], set[setOffset - 1] or set[setLength - 1]
    @_setContent cube[@_faceSequence[bottomAdj]], set[setOffset + 1] or set[0]


  _setContent: (el, content) ->
    if @_urlRx.test content
      el.innerHTML = ''
      el.style.backgroundImage = "url(#{ content })"
    else
      el.innerHTML = content


  _getTransform: (deg) ->
    "translate(0, 0) translateZ(-#{ @size }px) rotate3d(1, 0, 0, #{ deg }deg)"


  _onTouchStart: (e, cube) ->
    e.preventDefault()
    @_touchStarted = true
    e.currentTarget.classList.add 'no-tween'
    if e.type is 'mousedown'
      cube.y1 = e.pageY
    else
      cube.y1 = e.touches[0].pageY


  _onTouchMove: (e, cube) ->
    return unless @_touchStarted
    e.preventDefault()
    cube.diff = (e.pageY - cube.y1) * @_touchCoefficient
    cube.yDelta = cube.yLast - cube.diff
    @_setSides cube


  _onTouchEnd: (e, cube) ->
    @_touchStarted = false
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
    return unless @_touchStarted
    @_onTouchEnd e, cube if e.toElement and not cube.el.contains e.toElement



