// Generated by CoffeeScript 1.6.3
/*
Defines various custom events
	- Loops
*/

var Kelvi;

angular.module('CustomEvents', []).directive('loopEvents', function() {
  return function(scope, element, attrs) {
    if (scope.$first) {
      scope.$emit("ng-repeat:start", {
        "element": element[0],
        "attrs": attrs
      });
    }
    if (scope.$last) {
      scope.$emit("ng-repeat:complete", {
        "element": element[0],
        "attrs": attrs
      });
    }
  };
});

/*
	Load custom events for event handling
*/


Kelvi = angular.module('Kelvi', ['CustomEvents']);

Kelvi.controller('KelviController', function($scope, $http) {
  var _this = this;
  $scope.SO_URL = 'https://stackoverflow.com';
  $scope.$on("ng-repeat:complete", function() {
    return $scope.changeHeight();
  });
  $scope.SETTINGS = GlobalConfig;
  $scope.panels = [];
  /* Setup shortcuts*/

  $scope.get = function(prop) {
    return $scope.SETTINGS[prop] || null;
  };
  $scope.topics = function() {
    return GlobalConfig.topics;
  };
  $scope.dashboard = new KelviDashboard("Stacks");
  $scope.addTopic = function(topic) {
    var panel;
    panel = new KelviTopic(topic);
    panel.dataLoader = function(url) {
      return $http.jsonp(url);
    };
    return $scope.dashboard.addPanel(panel);
  };
  $scope.questions_watch = function(panel, watch) {
    return panel.questions(watch.category);
  };
  $scope.questions = function(panel) {
    var watch, _i, _len, _ref;
    _ref = panel.watches();
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      watch = _ref[_i];
      if (watch.show) {
        return panel.questions(watch.category);
      }
    }
  };
  $scope.changeHeight = function() {
    var h, max;
    max = -999999;
    $(".topic").each(function(k, o) {
      $(o).css('height', '100%');
      return max = Math.max(max, $(o).height());
    });
    h = max < ($scope.SETTINGS.questionsCount * 50) ? ($scope.SETTINGS.questionsCount * 45) + "px" : max;
    $(".topic").height(h);
  };
  $(window).resize($scope.changeHeight);
  $scope.init = function() {
    var cfg, topic, _ref;
    console.log($scope.topics());
    _ref = $scope.topics();
    for (topic in _ref) {
      cfg = _ref[topic];
      $scope.addTopic(topic);
    }
    $scope.panels = $scope.dashboard.get("panels");
  };
  $scope.new_data = function(data, topic) {
    $scope.$emit("Kelvi:update", {
      "data": data,
      "topic": topic
    });
    return this;
  };
  $scope.addNewTopic = function() {
    var topics;
    topics = $scope.SETTINGS.topics;
    if (topics.indexOf($scope.newTopic) > -1) {

    } else {
      return topics.push($scope.newTopic);
    }
  };
  $scope.removeTopic = function(item) {
    var topics;
    topics = $scope.SETTINGS.topics;
    topics.splice(topics.indexOf(item), 1);
  };
});

Kelvi.controller('KelviConfigController', function($scope, $http) {
  $scope.topics = function() {
    return GlobalConfig.topics;
  };
  $scope.addNewTopic = function() {
    updateConfig($scope.newTopic);
    return $scope.newTopic = '';
  };
  $scope.removeTopic = function(topic) {
    delete GlobalConfig.topics[topic];
    return saveConfig();
  };
  $scope.watchesAvailable = function(topic) {
    var k, watch, watches, _ref;
    watches = [];
    _ref = GlobalConfig.topics[topic].watches;
    for (k in _ref) {
      watch = _ref[k];
      if (watch.enable) {
        watches.push(watch);
      }
    }
    return watches;
  };
  $scope.getHttpCallsFreq = function() {
    var cfg, count, freq, freq1, topic, watchesCount, _ref;
    count = 0;
    freq = 0;
    _ref = GlobalConfig.topics;
    for (topic in _ref) {
      cfg = _ref[topic];
      watchesCount = $scope.watchesAvailable(topic).length;
      freq1 = watchesCount * (1000 * 60 * 60) / parseInt(GlobalConfig.topics[topic].refreshRate);
      freq1 = freq1 / 60;
      count += watchesCount;
      freq += freq1;
    }
    return {
      'count': count,
      'freq': freq
    };
  };
  $scope.config = function(topic) {
    return GlobalConfig.topics[topic];
  };
  $scope.saveConfig = function() {
    return saveConfig();
  };
  return $scope.decideWatchToShow = function(topic, watch) {
    var watches;
    watches = $scope.watchesAvailable(topic);
    if (watch.enable) {
      watches[1].show = false;
    } else if (!watch.enable) {
      watches[0].show = true;
    }
    return watch.show = watch.enable;
  };
});