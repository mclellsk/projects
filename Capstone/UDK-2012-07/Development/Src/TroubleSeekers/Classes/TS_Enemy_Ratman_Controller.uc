class TS_Enemy_Ratman_Controller extends UTBot;

var Actor Destination;

/* Event:
 * ExecuteWhatToDoNext()
 * Description:
 * Decides what the bot should do next, moves the bot to the roaming state.
 */
protected event ExecuteWhatToDoNext()
{
  GotoState('Roaming');
}

/* Function:
 * Destroyed()
 * Description:
 * Function controls what occurs when the enemy is dead.
 */
simulated function Destroyed()
{
	`log("Enemy Destroyed");
	super.Destroyed();
}

/* State:
 * Roaming
 * Description:
 * Controls the bot behaviour during the roaming state. Picks a destination, moves to the destination.
 */
state Roaming
{
	Begin:
	  //Pick a destination
	  if(Destination == none || Pawn.ReachedDestination(Destination))
	  {
		Destination = FindRandomDest();
	  }

	  //Find path to destination
	  MoveToward(FindPathToward(Destination), FindPathToward(Destination));
	  LatentWhatToDoNext();
}

defaultproperties
{
}