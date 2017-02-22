class TS_Notification extends Actor;

var string Message;
var bool bRemoveNotification;
var bool bCreated;

function Initialize(float time, string msg)
{
	bRemoveNotification = false;
	bCreated = false;
	SetTimer(time, false, 'DeleteTimer');
	Message = msg;
}

function DeleteTimer()
{
	bRemoveNotification = true;	
}

DefaultProperties
{
}
