(function(){
	var legorafi_app = angular.module('legorafi_app', []);

	legorafi_app.controller('pages_ctrl', function ($scope){
		this.links = pages;
		$scope.predicate = 'comments'
		$scope.reverse = true;
		$scope.order = function(predicate){
			$scope.reverse = ($scope.predicate === predicate) ? !$scope.reverse : false;
			$scope.predicate = predicate;
		};
	});
})();
