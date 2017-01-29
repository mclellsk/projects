app.controller("appCtrl", ['$scope', '$http', '$location', '$window', AppController]);

function AppController($scope,$http,$location,$window)
{
	$scope.link = "";
	$scope.registered = 0;
	$scope.result = 0;
	$scope.email = "";
	$scope.pw = "";
	$scope.regEmail = "";
	$scope.regPw = "";
	$scope.regConfirmPw = "";
	$scope.register = function()
	{
		var parameter = JSON.stringify({ email:$scope.regEmail, password:$scope.regPw });
		$http.post('/register.php', parameter).
		success(function(data)
		{ 
			var result = angular.fromJson(data);
			$scope.registered = result['registered'];
			$scope.link = result['url'];
		}).
		error(function(data, status, headers, config){});
	};
	$scope.login = function()
	{
		var parameter = JSON.stringify({ login:true, email:$scope.email, password:$scope.pw });
		$http.post('/login.php', parameter).
		success(function(data)
		{ 
			var result = angular.fromJson(data);
			$scope.result = result['isLogged'];
		}).
		error(function(data, status, headers, config){});
	};
	$scope.logout = function()
	{
		var parameter = JSON.stringify({ login:false });
		$http.post('/login.php', parameter).
		success(function(data)
		{
			var result = angular.fromJson(data);
			$scope.result = result['isLogged'];
			$window.location.href = "http://localhost/index.php";
		}).
		error(function(data, status, headers, config){});
	};
	$scope.status = function()
	{
		$http.get('/status.php').
		success(function(data)
		{
			var result = angular.fromJson(data);
			$scope.result = result['isLogged'];
		}).
		error(function(){});
	};
	$scope.status();
}