<?php	
	require_once "access.php";
	Session::GetSession();
	$result = array('isLogged' => $_SESSION['isLogged']);
	header('Content-Type: application/json');
	echo json_encode($result);
?>