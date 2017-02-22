class TS_FloatDmg extends Actor;

var string Message;
var Vector Position;
var bool bRemoveNotification;
var bool bCreated;

function Initialize(Vector pos, float time, string msg)
{
	bRemoveNotification = false;
	bCreated = false;
	SetTimer(time, false, 'DeleteTimer');
	Message = msg;
	Position = pos;
}

function DeleteTimer()
{
	bRemoveNotification = true;	
}

DefaultProperties
{
}