<?php	
	require_once "access.php";
	$postdata = file_get_contents("php://input");
	$request = json_decode($postdata);
	$user = $request->email;
	$pass = $request->password;
	$result = Session::Register($user,$pass);
	$txt = "";
	if ($result[0] > 0)
	{
		$url = "http://localhost";
		$txt = $url . "/verify.php?user=" . $user . "&code=" . $result[1];
	}
	$json = json_encode(array('url' => $txt, 'registered' => $result[0]));
	header('Content-Type: application/json');
	echo $json;
?>