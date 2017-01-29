<?php require_once "template.php"; ?>
<html>
	<head>
		<title>Main Page</title>
		<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">
	</head>
	<body ng-app="appName" ng-controller="appCtrl">
		<?php Template::Navigation(); ?>
		<div class="container-fluid">
			<div class="row" ng-show="result <= 0">
				<form ng-submit="login()" class="container-fluid">
					<div class="row">
						<div class="col-md-8">
							<div class="row">
								<div class="col-md-6">
									<div class="form-group input-group">
										<span class="input-group-addon" id="basic-addon1">@</span>
										<input ng-model="email" type="email" class="form-control" placeholder="E-mail" aria-describedby="basic-addon1" required>
									</div>
								</div>
							</div>
							<div class="row">
								<div class="col-md-6">
									<div class="form-group">
										<input ng-model="pw" type="password" class="form-control" placeholder="Password" required>
									</div>
								</div>
							</div>
							<div class="row">
								<div class="col-md-6">
									<div class="form-group">
										<button type="submit" class="btn btn-default">Login</button>
									</div>
								</div>
							</div>
						</div>
					</div>
				</form>
			</div>
			<div class="row">
				<div class="col-md-12 text-danger" ng-show="result == -1">
				 <blockquote>Account does not exist.</blockquote>
				</div>
				<div class="col-md-12 text-danger" ng-show="result == -2">
				 <blockquote>Incorrect password or account not activated.</blockquote>
				</div>
				<div class="col-md-12 text-confirm" ng-show="result > 0">
				 <blockquote>Successfully logged in!</blockquote>
				</div>
			</div>
		</div>
		<script src="https://ajax.googleapis.com/ajax/libs/angularjs/1.4.8/angular.min.js"></script>
		<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.4/jquery.min.js"></script>
		<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js" integrity="sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa" crossorigin="anonymous"></script>
		<script src="/js/app.js"></script>
		<script src="/js/controller.js"></script>
	</body>
</html>