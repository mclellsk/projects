class TS_ConversationManager extends Actor;

/* Struct:
 * NPCResponse
 * Description:
 * This struct makes up the entity which represents an NPC response. Contains the string of the response which the NPC will
 * give the player, and the correlating set of player responses (array of indices for Conversation.PlayerResponses).
 */
struct NPCResponse
{
	var string Response;
	var array<int> PlayerResponseIndices;
};

/* Struct:
 * PlayerResponse
 * Description:
 * This struct makes up the entity which represents a player response. Contains the string which the player will
 * respond with, and the correlating NPCResponse (index in Conversation.NPCResponses array) for a given player response.
 */
struct PlayerResponse
{
	var string Response;
	var int NPCResponseIndex;
};

/* Struct:
 * Conversation
 * Description:
 * This struct makes up the entity which represents a conversation. A conversation is made up of an array of possible NPC responses,
 * and a set of player responses. Each conversation has a unique set of these arrays.
 */
struct Conversation
{
	var array<NPCResponse> NPCResponses;
	var array<PlayerResponse> PlayerResponses;
};

//Array of all possible Conversations
var array<Conversation> ConversationList;
//Bool that flags whether the player is currently in a conversation or not. (this controls visibility of conversation menu)
var bool bInConversation;

struct ConversationState
{
	var int NPCId;
	var int ConversationIndex;
};

var array<ConversationState> ConversationsStarted;

struct Decisions
{
	var int ConversationId;
	var int NPCResponseId;
	var array<int> PlayerResponses;
};

//Array of choices made per Conversation
var array<Decisions> DecisionList;

//Stores the state of each conversation started with an NPC (tracked by id)
function SetConversation(int NPCId, int ConversationIndex)
{
	local ConversationState conState;
	local int index;

	index = ConversationsStarted.Find('NPCId', NPCId);
	if (index == -1)
	{
		conState.NPCId = NPCId;
		conState.ConversationIndex = ConversationIndex;
		ConversationsStarted.AddItem(conState);
	}
	else
	{
		ConversationsStarted[index].ConversationIndex = ConversationIndex;
	}
}

//If decision made is not part of the set of decisions already made for the conversation during the current npc response, add it to the list.
function AddDecision(int conId, int NPCRespId, int Decision)
{
	local int i;
	local bool bDecisionExists;
	local Decisions decisionsMade;

	bDecisionExists = false;

	for (i = 0; i < DecisionList.Length; i++)
	{
		if (DecisionList[i].ConversationId == conId && DecisionList[i].NPCResponseId == NPCRespId)
		{
			if (DecisionList[i].PlayerResponses.Find(Decision) == -1)
			{
				bDecisionExists = true;
				DecisionList[i].PlayerResponses.AddItem(Decision);
			}
		}
	}

	if (!bDecisionExists)
	{
		decisionsMade.ConversationId = conId;
		decisionsMade.NPCResponseId = NPCRespId;
		decisionsMade.PlayerResponses.AddItem(Decision);
		DecisionList.AddItem(decisionsMade);
	}
}

function bool CheckDecision(int conId, int NPCRespId, int Decision)
{
	local int i;
	local bool bDecisionExists;

	for (i = 0; i < DecisionList.Length; i++)
	{
		if (DecisionList[i].ConversationId == conId && DecisionList[i].NPCResponseId == NPCRespId)
		{
			if (DecisionList[i].PlayerResponses.Find(Decision) != -1)
			{
				bDecisionExists = true;
				return True;
			}
		}
	}

	if (!bDecisionExists)
	{
		return False;
	}
}

/* Function:
 * Initialize()
 * Description:
 * This function is where all conversations that are in the game will be created and then stored in the ConversationManager.
 */
function Initialize()
{
	local array<int> responses;
	
	//Initialize to false, true at the beginning of conversations, false at the end of conversations.
	bInConversation = false;

	//For: Billy The Old (Neutral Villager 1)
	//Conversation 1[0] - Initial Conversation
	AddConversation();
	responses = ClearIntArray();
	responses.AddItem(0);
	responses.AddItem(1);
	responses.AddItem(2);
	responses.AddItem(3);
	AddNPCResponse(0, "Hello youngling, the path ahead is treacherous and paved with evils, are you sure this is the place you want to be?", responses); //NPC R0
	AddPlayerResponse(0, "I have to be here, I must find my friends.", 1); // Player R0
	AddPlayerResponse(0, "What do you mean… evils?", 2); // Player R1
	AddPlayerResponse(0, "I laugh in the face of danger. You hear that danger? HAHA!", 3); // Player R2
	AddPlayerResponse(0, "Oh, you’re right, I shouldn’t be here. I’ll find my way out…", 4); // Player R3
	responses = ClearIntArray();
	responses.AddItem(4);
	responses.AddItem(5);
	responses.AddItem(6);
	AddNPCResponse(0, "Find your friends you say? Perhaps they are deeper in the dungeon, be wary though, every step is like rolling the dice against Death.", responses); //1
	AddPlayerResponse(0, "I like those odds.", 3); //Player R4
	AddPlayerResponse(0, "Death is inevitable, but what I do with the time I’m given is up to me.", 3); //Player R5
	AddPlayerResponse(0, "What do you mean?", 2); //Player R6
	responses = ClearIntArray();
	responses.AddItem(7);
	responses.AddItem(8);
	responses.AddItem(9);
	AddNPCResponse(0, "I mean… there are traps all over this keep, if you aren’t careful, you can lose a lot more than your friends.", responses); //2
	AddPlayerResponse(0, "If I lose them, I’ve already lost everything...", 5); //Player R7
	AddPlayerResponse(0, "Thank you for the help, but I have to keep going.", 3); //Player R8
	AddPlayerResponse(0, "Can you give me any more advice?", 4); //Player R9
	responses = ClearIntArray();
	responses.AddItem(10);
	responses.AddItem(11);
	AddNPCResponse(0, "You are a much braver person than I. Perhaps this will help you on your journey ahead.", responses); //3
	AddPlayerResponse(0, "Thank you, I’ll try to clear the way and send help once I get out.", 6); //Player R10
	AddPlayerResponse(0, "You old fool. Your cowardice is your downfall, you are deserving of these halls.", 7); //Player R11
	responses = ClearIntArray();
	responses.AddItem(12);
	responses.AddItem(11);
	AddNPCResponse(0, "The only way out is far too risky for me to take, I never found what lies ahead after the first trap I met. My journey has been halted here for 50 years as there is no way back… only forward.", responses); //4
	AddPlayerResponse(0, "So wait… you’ve never left this dungeon? How have you survived?", 8); //Player R12
	responses = ClearIntArray();
	responses.AddItem(10);
	responses.AddItem(13);
	AddNPCResponse(0, "I understand. Take this with you. May it help your journey where it could not mine.", responses); //5
	AddPlayerResponse(0, "May you rot here forever…", 7); //Player R13
	responses = ClearIntArray();
	responses.AddItem(14);
	AddNPCResponse(0, "Much obliged. I’ll go back to standing as still as possible, hopefully the darkness stays blind to my presence.", responses); //6
	AddPlayerResponse(0, "Goodbye.", -1); //Player R14
	responses = ClearIntArray();
	responses.AddItem(15);
	AddNPCResponse(0, "I hope a giant creature in the darkness takes the last breath from your body. Fifty years down here and I had to run into you before I die, thanks for nothing you punk. I’m so angry I could just stand perfectly still for another 50 years.", responses); //7
	AddPlayerResponse(0, "I’ll make sure to let the monsters know where you are gramps.", -1); //Player R15
	responses = ClearIntArray();
	responses.AddItem(16);
	responses.AddItem(17);
	AddNPCResponse(0, "Eating rats and standing still. Once you get over the squeals they make, they are actually quite delicious.", responses); //8
	AddPlayerResponse(0, "Whoa... I’ll see if I can get you some real food once I get out.", 6); //Player R16
	AddPlayerResponse(0, "Whoa… You are completely deranged; it’s good that you are trapped here. Perhaps I should put you out of your misery?", 7); //Player R17
	//Conversation 2[1] - Post-Conversation
	AddConversation();
	responses = ClearIntArray();
	responses.AddItem(0);
	responses.AddItem(1);
	AddNPCResponse(1, "I have nothing else to say...", responses);
	AddPlayerResponse(1, "Goodbye.", -1);
	AddPlayerResponse(1, "Good riddance.", -1);

	//For: Ratty Man (Neutral Villager 2)
	//Conversation 3[2] - Initial Conversation
	AddConversation();
	responses = ClearIntArray();
	responses.AddItem(0);
	responses.AddItem(1);
	AddNPCResponse(2, "Got any cheese! No one seems to recognize me down here...", responses); //NPC R0
	AddPlayerResponse(2, "Do you think you're a rat? Because you aren't.", 1); // Player R0
	AddPlayerResponse(2, "I have no time for this, where are my friends!", 2); // Player R1
	responses = ClearIntArray();
	responses.AddItem(2);
	responses.AddItem(3);
	AddNPCResponse(2, "What are you? Some kind of jokester? I know what I am.. But I am getting angered by the lack of communication between me and my rat brothers.", responses); //NPC R1
	AddPlayerResponse(2, "That's because you aren't a rat you fool. I'm done with crazies, I need to get back on track and find my friends.", 2);
	AddPlayerResponse(2, "I know what I would do if I were you, I can't stand it when people ignore me.", 3); 
	responses = ClearIntArray();
	responses.AddItem(4);
	responses.AddItem(5);
	AddNPCResponse(2, "Your friends you say... well, I can help you with that. But first you need to learn to harness your powers.", responses); //NPC R2
	AddPlayerResponse(2, "Go on..", 4);
	AddPlayerResponse(2, "Silence fool, the time for talk is over.", -1); //Give Quest - Kill Ratty Man
	responses = ClearIntArray();
	responses.AddItem(6);
	responses.AddItem(7);
	AddNPCResponse(2, "Hmm, teach them a lesson? Maybe you could do it for me, I'd sweeten the deal. But first you need to learn to harness you powers to slay my brothers in combat.", responses); //NPC R2
	AddPlayerResponse(2, "Go on..", 4);
	AddPlayerResponse(2, "Just point me in the direction, I'll do it.", -1); //Give Quest - Kill 20 rat men
	responses = ClearIntArray();
	responses.AddItem(8);
	AddNPCResponse(2, "Pressing the I hotkey opens your inventory. There are 2 kinds of tablets in this world, Passives and Actives. You need to cast your actives using the number keys, however your passives just need to be equipped to be in effect.", responses); //NPC R2
	AddPlayerResponse(2, "Go on..", 5);
	responses = ClearIntArray();
	responses.AddItem(9);
	AddNPCResponse(2, "Dragging the passives to a slot above an active will usually append the spell equipped below it. However some passives just influence your player statistics, which can be seen by pressing C.", responses); //NPC R5
	AddPlayerResponse(2, "Go on..", 6);
	responses = ClearIntArray();
	responses.AddItem(10);
	AddNPCResponse(2, "If you want a bit more brute force, you can always just beat your enemies to death using the MOUSE-LEFT and MOUSE-RIGHT buttons.", responses); //NPC R5
	AddPlayerResponse(2, "Go on..", 7);
	responses = ClearIntArray();
	responses.AddItem(11);
	responses.AddItem(12);
	AddNPCResponse(2, "Now that you have a better understanding on how to survive in the cold reality that is our world, I will give you a task. You can track this by pressing Q.", responses); //NPC R7
	AddPlayerResponse(2, "Thanks, but I'm still not taking a chance with a half-in-the-door lunatic who thinks hes a rat.", -1); //GIVE QUEST - KILL RATTY MAN
	AddPlayerResponse(2, "Thanks, I'll go slay your rat brothers now... *Under Breath* Yeah that's a normal thing to say.", -1); //GIVE QUEST - KILL RAT MEN
	//Conversation 4[3] - Post-Conversation
	AddConversation();
	responses = ClearIntArray();
	responses.AddItem(0);
	responses.AddItem(1);
	AddNPCResponse(3, "I don't want to hear from you again unless you're back with some cheese.", responses);
	AddPlayerResponse(3, "I'll never get cheese for the likes of you, VERMIN! Perhaps a tad overdramatic.", -1);
	AddPlayerResponse(3, "I'll be going now...", -1);

}

/* Function:
 * AddConversation()
 * Description:
 * This function creates an empty conversation and appends that to the list of conversations.
 */
function AddConversation()
{
	local Conversation conversationTree;
	ConversationList.AddItem(conversationTree);
}

function array<int> ClearIntArray()
{
	local array<int> i;
	return i;
}

/* Function:
 * AddNPCResponse(int conversationId, string response, array<int> playerReponsesId)
 * Description:
 * This function creates an NPCResponse for the conversation specified, with the response and set of player responses corresponding to the conversation's associated playerresponses array.
 */
function AddNPCResponse(int conversationId, string response, array<int> playerResponsesId)
{
	local NPCResponse newNPCResponse;

	newNPCResponse.PlayerResponseIndices = playerResponsesId;
	newNPCResponse.Response = response;

	ConversationList[conversationId].NPCResponses.AddItem(newNPCResponse);
}

/* Function:
 * AddPlayerResponse(int conversationId, string response, int NPCResponseId)
 * Description:
 * This function creates a PlayerResponse for the conversation specified, with the response and NPCresponse corresponding to the conversation's associated playerresponses array.
 */
function AddPlayerResponse(int conversationId, string response, int NPCResponseId)
{
	local PlayerResponse newPlayerResponse;

	newPlayerResponse.NPCResponseIndex = NPCResponseId;
	newPlayerResponse.Response = response;

	ConversationList[conversationId].PlayerResponses.AddItem(newPlayerResponse);
}


DefaultProperties
{
}
