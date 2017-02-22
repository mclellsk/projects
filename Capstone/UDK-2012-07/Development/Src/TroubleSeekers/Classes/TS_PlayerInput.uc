class TS_PlayerInput extends UTPlayerInput within myPlayerController
config(Input);

simulated exec function ChangeInputBinding(name BindName, string Command)
{
	local int BindIndex;

	if (Command == "none")
		Command = "";

	for( BindIndex = Bindings.Length-1; BindIndex >= 0; BindIndex--)
	{
		if(Bindings[BindIndex].Name == BindName)
		{
			Bindings[BindIndex].Command = Command;
			SaveConfig();
			return;
		}
	}
}


DefaultProperties
{
}
