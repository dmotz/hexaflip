// Generated by CoffeeScript 1.6.2
(function() {
  var getSeq, logoSettings, makeObj, text1, text2;

  text1 = 'HEXA'.split('');

  text2 = 'FLIP'.split('');

  logoSettings = {
    size: 120,
    margin: 8,
    fontSize: 82,
    perspective: 450
  };

  makeObj = function(a) {
    var i, o, v, _i, _len;

    o = {};
    for (i = _i = 0, _len = a.length; _i < _len; i = ++_i) {
      v = a[i];
      o['letter' + i] = a;
    }
    return o;
  };

  getSeq = function(a, reverse, random) {
    var i, len, o, p, v, _i, _len;

    o = {};
    len = a.length;
    for (i = _i = 0, _len = a.length; _i < _len; i = ++_i) {
      v = a[i];
      if (reverse) {
        p = len - i - 1;
      } else if (random) {
        p = Math.floor(Math.random() * len);
      } else {
        p = i;
      }
      o['letter' + i] = a[p];
    }
    return o;
  };

  document.addEventListener('DOMContentLoaded', function() {
    var action, hexaLogo1, hexaLogo2, hexaPhoto, hexaTime, i, logos, photoControls, _fn, _i, _len, _ref;

    logos = document.getElementsByClassName('logo');
    hexaLogo1 = new HexaFlip(logos[0], makeObj(text1), logoSettings);
    hexaLogo2 = new HexaFlip(logos[1], makeObj(text2), logoSettings);
    hexaPhoto = new HexaFlip(document.getElementById('photo-demo'), {
      photos: (function() {
        var _i, _results;

        _results = [];
        for (i = _i = 1; _i <= 18; i = ++_i) {
          _results.push("./demo/images/" + i + ".jpg");
        }
        return _results;
      })()
    }, {
      size: 400
    });
    photoControls = document.getElementById('photo-controls');
    _ref = ['flipBack', 'flip'];
    _fn = function(action) {
      return photoControls.children[i].addEventListener('click', (function() {
        return hexaPhoto[action]();
      }), false);
    };
    for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
      action = _ref[i];
      _fn(action);
    }
    hexaTime = new HexaFlip(document.getElementById('time-demo'), null, {
      size: 150,
      fontSize: 100
    });
    setTimeout(function() {
      hexaLogo1.setValue(getSeq(text1, true));
      return hexaLogo2.setValue(getSeq(text2, true));
    }, 0);
    setTimeout(function() {
      hexaLogo1.setValue(getSeq(text1));
      return hexaLogo2.setValue(getSeq(text2));
    }, 1000);
    setTimeout(function() {
      return setInterval(function() {
        hexaLogo1.setValue(getSeq(text1, false, true));
        return hexaLogo2.setValue(getSeq(text2, false, true));
      }, 3000);
    }, 5000);
    return setTimeout(function() {
      var hour, meridian, minute, now;

      now = new Date;
      hour = now.getHours();
      minute = now.getMinutes().toString();
      if (hour > 12) {
        hour = (hour - 12).toString();
        meridian = 'pm';
      } else {
        meridian = 'am';
        if (hour === 0) {
          hour = 12;
        }
        hour = hour.toString();
      }
      if (minute.length > 1) {
        minute = minute.substr(0, 1) + '0';
      } else {
        minute = '00';
      }
      return hexaTime.setValue({
        hour: hour,
        minute: minute,
        meridian: meridian
      });
    }, 1);
  }, false);

}).call(this);
