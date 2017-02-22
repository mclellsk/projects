using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Input;

namespace XNABaseLibrary
{
    public static class KeyEvents
    {
        //Checks to see if a key has been tapped.
        public static bool isKeyTapped(Keys key, KeyboardState _newState, KeyboardState _oldState)
        {
            return (_newState.IsKeyUp(key) && _oldState.IsKeyDown(key));
        }

        //Checks to see if a key has been held down.
        public static bool isKeyHeld(Keys key, KeyboardState _newState, KeyboardState _oldState)
        {
            return (_newState.IsKeyDown(key) && _oldState.IsKeyDown(key));
        }

        public static bool isKeyPressed(Keys key, KeyboardState _newState, KeyboardState _oldState)
        {
            return (_newState.IsKeyDown(key) && _oldState.IsKeyUp(key));
        }
    }
}
