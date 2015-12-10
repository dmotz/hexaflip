// Generated by CoffeeScript 1.9.3
(function() {
  var demoText, getSeq, logoSettings, makeObj;

  demoText = ['HEXA'.split(''), 'FLIP'.split('')];

  logoSettings = {
    size: 120,
    margin: 8,
    fontSize: 82,
    perspective: 450
  };

  makeObj = function(a) {
    var i, j, len1, o, v;
    o = {};
    for (i = j = 0, len1 = a.length; j < len1; i = ++j) {
      v = a[i];
      o['letter' + i] = a;
    }
    return o;
  };

  getSeq = function(a, reverse, random) {
    var i, j, len, len1, o, p, v;
    o = {};
    len = a.length;
    for (i = j = 0, len1 = a.length; j < len1; i = ++j) {
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
    var action, fn, hexaPhoto, hexaTime, i, j, len1, logos, n, photoControls, ref, textDemos;
    logos = document.getElementsByClassName('logo');
    textDemos = (function() {
      var j, results;
      results = [];
      for (n = j = 0; j <= 1; n = ++j) {
        results.push(new HexaFlip(logos[n], makeObj(demoText[n]), logoSettings));
      }
      return results;
    })();
    hexaPhoto = new HexaFlip(document.getElementById('photo-demo'), {
      photos: (function() {
        var j, results;
        results = [];
        for (i = j = 1; j <= 18; i = ++j) {
          results.push("./demo/images/" + i + ".jpg");
        }
        return results;
      })()
    }, {
      size: 400,
      horizontalFlip: true
    });
    photoControls = document.getElementById('photo-controls');
    ref = ['flipBack', 'flip'];
    fn = function(action) {
      return photoControls.children[i].addEventListener('click', (function() {
        return hexaPhoto[action]();
      }), false);
    };
    for (i = j = 0, len1 = ref.length; j < len1; i = ++j) {
      action = ref[i];
      fn(action);
    }
    hexaTime = new HexaFlip(document.getElementById('time-demo'), null, {
      size: 150,
      fontSize: 100
    });
    setTimeout(function() {
      var k;
      for (n = k = 0; k <= 1; n = ++k) {
        textDemos[n].setValue(getSeq(demoText[n], true));
      }
      return null;
    }, 0);
    setTimeout(function() {
      var k;
      for (n = k = 0; k <= 1; n = ++k) {
        textDemos[n].setValue(getSeq(demoText[n]));
      }
      return null;
    }, 1000);
    setTimeout(function() {
      return setInterval(function() {
        var k;
        for (n = k = 0; k <= 1; n = ++k) {
          textDemos[n].setValue(getSeq(demoText[n], false, true));
        }
        return null;
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

//# sourceMappingURL=demo.js.map
