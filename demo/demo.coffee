text1 = 'HEXA'.split ''
text2 = 'FLIP'.split ''
logoSettings =
    size: 120,
    margin: 8,
    fontSize: 82,
    perspective: 450

makeObj = (a) ->
  o = {}
  o['letter' + i] = a for v, i in a
  o

getSeq = (a, reverse, random) ->
  o = {}
  len = a.length
  for v, i in a
    if reverse
      p = len - i - 1
    else if random
      p = Math.floor Math.random() * len
    else
      p = i
    o['letter' + i] = a[p]
  o

document.addEventListener 'DOMContentLoaded', ->
  logos = document.getElementsByClassName 'logo'
  hexaLogo1 = new HexaFlip logos[0], makeObj(text1), logoSettings
  hexaLogo2 = new HexaFlip logos[1], makeObj(text2), logoSettings
  hexaPhoto = new HexaFlip document.getElementById('photo-demo'),
    {photos: ("./demo/images/#{ i }.jpg" for i in [1..18])},
    size: 400
    horizontalFlip: true

  photoControls = document.getElementById 'photo-controls'

  for action, i in ['flipBack', 'flip'] then do (action) ->
    photoControls.children[i].addEventListener 'click', (-> hexaPhoto[action]()), false

  hexaTime = new HexaFlip document.getElementById('time-demo'), null, size: 150, fontSize: 100

  setTimeout ->
    hexaLogo1.setValue getSeq text1, true
    hexaLogo2.setValue getSeq text2, true
  , 0

  setTimeout ->
    hexaLogo1.setValue getSeq text1
    hexaLogo2.setValue getSeq text2
  , 1000

  setTimeout ->
      setInterval ->
          hexaLogo1.setValue getSeq text1, false, true
          hexaLogo2.setValue getSeq text2, false, true
      , 3000
  , 5000


  setTimeout ->
    now = new Date
    hour = now.getHours()
    minute = now.getMinutes().toString()

    if hour > 12
      hour = (hour - 12).toString()
      meridian = 'pm'
    else
      meridian = 'am'
      hour = 12 if hour is 0
      hour = hour.toString()

    if minute.length > 1
      minute = minute.substr(0, 1) + '0'
    else
      minute = '00'

    hexaTime.setValue {hour, minute, meridian}

  , 1


, false
