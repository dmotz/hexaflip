# hexaFlip
# 0.0.1
# Dan Motzenbecker
# http://oxism.com
# Copyright 2013, MIT License

baseName = 'hexaflip'
className = baseName[0].toUpperCase() + baseName.slice 1
testEl = document.createElement 'div'
prefixList = ['Webkit', 'Moz', 'O', 'ms']
transform = do ->
  return 'transform' if testEl.style.transform?
  for prefix in prefixList
    prefixed = prefix + 'Transform'
    return prefixed if testEl.style[prefixed]?
  false


class window.Hexaflip

  className: baseName
  _touchCoefficient: .7
  _urlRx: /^((https?:)?\/\/)|(data:)/
  _faceNames: ['front', 'bottom', 'back', 'top', 'left', 'right']
  _faceSequence: @::_faceNames.slice 0, 4

  constructor: (@el, @sets) ->
    unless transform
      console?.warn "#{ baseName }: CSS transforms are not supported in this browser."
      return

    @_cubes = {}
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

    @el.classList.add @className
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

    for side in @_faceNames
      cube[side] = document.createElement 'div'
      cube[side].className = @className + '-' + side
      cube.el.appendChild cube[side]

    for eventType in ['MouseDown', 'MouseMove', 'MouseUp', 'MouseOut'] then do (eventType) =>
      cube.el.addEventListener eventType.toLowerCase(), (e) =>
        @['_on' + eventType] e, cube
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
    cube.el.style[transform] = @_getTransform cube.yDelta
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
    "translate(0, 0) translateZ(-280px) rotate3d(1, 0, 0, #{ deg }deg)"


  _onMouseDown: (e, cube) ->
    e.preventDefault()
    @_touchStarted = true
    e.currentTarget.classList.add 'no-tween'
    cube.y1 = e.pageY


  _onMouseMove: (e, cube) ->
    e.preventDefault()
    return unless @_touchStarted
    cube.diff = (e.pageY - cube.y1) * @_touchCoefficient
    cube.yDelta = cube.yLast - cube.diff
    @_setSides cube


  _onMouseUp: (e, cube) ->
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
      console.log 'wtf'
      cube.yLast -= cube.yLast % 90

    cube.el.classList.remove 'no-tween'
    cube.el.style[transform] = @_getTransform cube.yLast


  _onMouseOut: (e, cube) ->
    return unless @_touchStarted
    @_onMouseUp e, cube if e.toElement and not cube.el.contains e.toElement


