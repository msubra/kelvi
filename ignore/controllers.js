var test_data = 
{
	"last_updated": "",
	"questions" : [
		{"id":"1","title":"question 1","url":"http://..."},
		{"id":"2","title":"question 2","url":"http://..."},
		{"id":"3","title":"question 3","url":"http://..."},
	]
};

var CACHE = null;

function KelviController($scope,$http) {

	$scope.SETTINGS = {
			'topics':['java','python','html'],
			'watchers': [{"id":'new',"title":"New"}] //'watchers': ['New','Unanswered','Watching']
	};

	$scope.topics = $scope.SETTINGS['topics'];
	$scope.watchers = $scope.SETTINGS['watchers'];

	$scope.QUESTIONS = 
	{

	};

	$($scope.topics).each(function(k,topic){
		$scope.QUESTIONS[topic] = {};

		$($scope.watchers).each(function(k,watcher){
			$scope.QUESTIONS[topic][watcher.id] = {};
		})

	});


	$scope.get = function(topic,watcher)
	{
		console.log(topic);
		var fn = 'get_' + watcher.id;
		if(fn in $scope)
		{
			console.log("found function:" + fn);
			return $scope[fn].call($scope,topic);
		};
	}

	$scope.get_questions = function(topic,watcher)
	{
		return $scope.QUESTIONS[topic][watcher].questions;
	}


	$scope.get_new = function(topic)
	{
		var return_data = {'last_updated':new Date(),'questions':[]};
		$.ajax({
		  dataType: "jsonp",
		  jsonp: 'jsonp',
		  url: "http://api.stackoverflow.com/1.1/search?tagged=java&min=10",
		}).done(function( data ) {

			for(var qno = 0; qno <= 10; qno++)
			{

				var _q = data.questions[qno];
				if ("closed_date" in _q)
				{
					qno--;
					continue;
				}
				/*
				answer_count: 2
				community_owned: false
				creation_date: 1388108504
				down_vote_count: 0
				favorite_count: 0
				last_activity_date: 1388111290
				last_edit_date: 1388108600
				owner: Object
				question_answers_url: "/questions/20793590/answers"
				question_comments_url: "/questions/20793590/comments"
				question_id: 20793590
				question_timeline_url: "/questions/20793590/timeline"
				score: 0
				tags: Array[4]
				title: "Binding json, that has a list, with an object using Jackson"
				up_vote_count: 0
				view_count: 9
				*/
				
				console.log(_q);
				var q = {"question_id":_q.question_id,"title":_q.title,"url":_q.question_answers_url};

				return_data['questions'].push(q);
			}

			$scope.update(return_data,topic,'new');

		});

		// $http({method: 'GET', url: 'http://api.stackoverflow.com/1.1/search?tagged=java&min=10'}).
		// 	success(function(data, status, headers, config) {
		// 	}).
		// 	error(function(data, status, headers, config) {
		// 	});

		return test_data;
	};



	$scope.update = function(data,topic,watcher)
	{

		$scope.QUESTIONS[topic][watcher] = data;
		console.log($scope.QUESTIONS[topic][watcher]);

	}

	$scope.get_unanswered = function(topic)
	{
		return test_data;
	};

	$scope.get_watching=function(topic)
	{
		return test_data;
	};


}


/** Initialize app **/
// var KelviApp = angular.module('KelviApp', [], function () {});

// KelviApp.controller('KelviController', ['$scope','$timeout','$filter', KelviController]);

// angular.element(document).ready(function () {
//     $.ajaxSetup({
//         cache: true,
//         headers: {
//             'Cache-Control': 'public'
//         }
//     });

//     var $instance = angular.bootstrap(document, ['KelviApp']);
//     var $scope = angular.element('body').scope();
//     $scope.init();

// });

