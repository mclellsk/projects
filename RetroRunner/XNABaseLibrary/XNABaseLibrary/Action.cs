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
    public class Action
    {
        Keys _key;

        //Link action to key.
        public Action(Keys key)
        {
            _key = key;
        }

        //Returns key that is in use for action.
        public Keys getKey()
        {
            return _key;
        }

        //Sets key of action to new key input.
        public void setKey(Keys newKey)
        {
            _key = newKey;
        }
    }
}
