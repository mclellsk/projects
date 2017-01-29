<?php	
	require_once "access.php";
	$postdata = file_get_contents("php://input");
	$request = json_decode($postdata);
	if ($request->login)
		Session::Login($request->email,$request->password);
	else
		Session::Logout();
	$result = array('isLogged' => $_SESSION['isLogged']);
	header('Content-Type: application/json');
	echo json_encode($result);
?>