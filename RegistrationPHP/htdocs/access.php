<?php
	class Session
	{
		public static function GetSession()
		{
			if (!session_id())
			{
				session_start();
			
				if (!isset($_SESSION['isLogged']))
					$_SESSION['isLogged'] = 0;
				if (!isset($_SESSION['email']))
					$_SESSION['email'] = "";
				if (!isset($_SESSION['password']))
					$_SESSION['password'] = "";
			}
		}
		
		public static function SetLoginState($state)
		{
			Session::GetSession();
			$_SESSION['isLogged'] = $state;
		}
		
		public static function CheckAccess()
		{
			Session::GetSession();
			
			Session::Login($_SESSION['email'], $_SESSION['password']);
			
			if ($_SESSION['isLogged'] <= 0)
			{
				header('Location: noaccess.php');
				die();
			}
		}
		
		public static function GetPDO()
		{
			require_once 'config.php';
			$pdo = new PDO("mysql:host=$dbhost;dbname=$dbname",$dbuser,$dbpw);
			return $pdo;		
		}
		
		public static function Logout()
		{
			Session::SetLoginState(0);
			$_SESSION['email'] = '';
			$_SESSION['password'] = '';
		}
		
		public static function Login($e, $pw)
		{
			try
			{
				if ($e !== "" && $pw !== "")
				{
					$pdo = Session::GetPDO();
					$sql = 'CALL Login(:user,:pass,@result);';
					$sp = $pdo->prepare($sql);
					$sp->bindParam(':user',$e,PDO::PARAM_STR,256);
					$sp->bindParam(':pass',$pw,PDO::PARAM_STR,256);
					$sp->execute();
					$sp->closeCursor();
					$row = $pdo->query('SELECT @result AS result')->fetch(PDO::FETCH_ASSOC);
					Session::SetLoginState($row['result']);
					if ($row['result'] > 0)
					{
						$_SESSION['email'] = $e;
						$_SESSION['password'] = $pw;
					}
				}
				else
				{
					Session::SetLoginState(-1);
				}
			}
			catch (PDOException $e)
			{
				Session::SetLoginState(-1);
				die();
			}
		}
		
		public static function Activate($email, $vcode)
		{
			try
			{
				if ($email !== "" && $vcode !== "")
				{
					$pdo = Session::GetPDO();
					$sql = 'CALL Activate(:user,:vcode,@result)';
					$sp = $pdo->prepare($sql);
					$sp->bindParam(':user',$email,PDO::PARAM_STR,256);
					$sp->bindParam(':vcode',$vcode,PDO::PARAM_STR,256);
					$sp->execute();
					$sp->closeCursor();
					$row = $pdo->query('SELECT @result AS result')->fetch(PDO::FETCH_ASSOC);
					return $row['result'];
				}
				else
				{
					return -1;
				}
			}
			catch (PDOException $e)
			{
				return -1;
				die();
			}
		}
		
		public static function Register($email, $password)
		{
			try
			{
				if ($email !== "" && $password !== "")
				{
					$pdo = Session::GetPDO();
					$sql = 'CALL Register(:user,:pass,@result,@vcode)';
					$sp = $pdo->prepare($sql);
					$sp->bindParam(':user',$email,PDO::PARAM_STR,256);
					$sp->bindParam(':pass',$password,PDO::PARAM_STR,256);
					$sp->execute();
					$sp->closeCursor();
					$row = $pdo->query('SELECT @result AS result, @vcode AS vcode')->fetch(PDO::FETCH_ASSOC);
					return array($row['result'],$row['vcode']);
				}
				else
				{
					return array(-1,"");
				}
			}
			catch (PDOException $e)
			{
				return array(-1,"");
				die();
			}
		}
	}
?>