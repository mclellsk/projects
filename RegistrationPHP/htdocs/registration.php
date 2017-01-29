<?php require_once "template.php"; ?>
<html>
	<head>
		<title>Registration Page</title>
		<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">
	</head>
	<body ng-app="appName" ng-controller="appCtrl">
		<?php Template::Navigation(); ?>
		<div class="container-fluid">
			<div ng-show="registered <= 0" class="row">
				<form name="formRegister" ng-submit="register()" class="container-fluid">
					<div class="row">
						<div class="col-md-8">
							<div class="row">
								<div class="col-md-6">
									<div class="form-group input-group">
										<span class="input-group-addon" id="basic-addon1">@</span>
										<input ng-model="regEmail" type="email" class="form-control" placeholder="E-mail" aria-describedby="basic-addon1" required>
									</div>
								</div>
							</div>
							<div class="row">
								<div class="col-md-6">
									<div class="form-group">
										<input id="regPw" name="regPw" ng-model="regPw" type="password" class="form-control" placeholder="Password" required>
									</div>
								</div>
							</div>
							<div class="row">
								<div class="col-md-6">
									<div class="form-group">
										<input id="regConfirmPw" name="regConfirmPw" ng-model="regConfirmPw" type="password" class="form-control" placeholder="Confirm Password" required pw-check="regPw">
										<span class="text-danger" ng-show="formRegister.regConfirmPw.$error.pwmatch">Passwords don't match!</span>
									</div>
								</div>
							</div>
							<div class="row">
								<div class="col-md-6">
									<div class="form-group">
										<button type="submit" class="btn btn-default" ng-disabled="formRegister.regConfirmPw.$error.pwmatch">Register</button>
									</div>
								</div>
							</div>
						</div>
					</div>
				</form>
			</div>
			<div class="row">
				<div class="col-md-12 text-danger" ng-show="registered < 0">
				 <blockquote>Registration failed.</blockquote>
				</div>
				<div class="col-md-12 text-confirm" ng-show="registered > 0">
				 <blockquote>Successfully registered, verify by clicking the <a href="{{link}}">link</a>.</blockquote>
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