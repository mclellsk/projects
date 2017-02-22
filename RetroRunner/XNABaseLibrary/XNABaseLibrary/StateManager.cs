using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Audio;
using Microsoft.Xna.Framework.Content;
using Microsoft.Xna.Framework.GamerServices;
using Microsoft.Xna.Framework.Graphics;
using Microsoft.Xna.Framework.Input;
using Microsoft.Xna.Framework.Media;

namespace XNABaseLibrary
{
    public class StateManager
    {
        Stack<GameState> _stateStack = new Stack<GameState>();

        public StateManager()
        {
        }

        //Pushes a state to the stack.
        public void pushStack(GameState state)
        {
            _stateStack.Push(state);
        }

        //Pops a state from the stack.
        public void popStack()
        {
            _stateStack.Pop();
        }

        //Loads the last state element in the stack (most recently pushed).
        public GameState loadStack()
        {
            return _stateStack.ElementAt<GameState>(0);//_stateStack.Count-1
        }

        public GameState loadPrevious()
        {
            return _stateStack.ElementAt<GameState>(1);
        }
    }
}
