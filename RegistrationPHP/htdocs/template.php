<?php
	class Template
	{
		public static function Navigation()
		{
			echo 
			'<div class="container-fluid">
			<h1>Login Tutorial</h1>
			</div>
			<nav class="navbar navbar-default">
				<div class="container-fluid">
					<div class="navbar-header">
						<button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#nav1" aria-expanded="false">
							<span class="glyphicon glyphicon-menu-hamburger" aria-hidden="true"></span>
						</button>
					</div>
					<div class="collapse navbar-collapse" id="nav1">
						<ul class="nav navbar-nav">
							<li><a href="/index.php">Login</a></li>
							<li><a href="/registration.php">Register</a></li>
							<li><a href="/locked.php">Locked</a></li>
						</ul>
						<form class="navbar-form navbar-right" ng-show="result > 0"><button ng-click="logout()" class="btn btn-default">Logout</button></form>
					</div>
				</div>
			</nav>';
		}
	}
?>

