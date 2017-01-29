<?php 
	require_once "template.php"; 
	require_once "access.php";
	$result = Session::Activate($_GET['user'], $_GET['code']);
?>
<html>
	<head>
		<title>Activate Account</title>
		<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">
	</head>
	<body ng-app="appName" ng-controller="appCtrl">
		<?php Template::Navigation(); ?>
		<div class="container-fluid">
			<div class="row">
				<?php
					if ($result > 0)
					{
						echo
						'<div class="col-md-12 text-confirm">
							<blockquote>Your account has been verified! Please login.</blockquote>
						</div>';
					}
					else
					{
						echo
						'<div class="col-md-12 text-danger">
							<blockquote>Your account could not be verified! Please try again.</blockquote>
						</div>';
					}
				?>
			</div>
		</div>
		<script src="https://ajax.googleapis.com/ajax/libs/angularjs/1.4.8/angular.min.js"></script>
		<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.4/jquery.min.js"></script>
		<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js" integrity="sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa" crossorigin="anonymous"></script>
		<script src="/js/app.js"></script>
		<script src="/js/controller.js"></script>
	</body>
</html>