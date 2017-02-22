using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using XNABaseLibrary;
using Microsoft.Xna.Framework.Input;

namespace RetroRunner
{
    public class Controls
    {
        //PLAYER CONTROLS
        public static XNABaseLibrary.Action pl_left = new XNABaseLibrary.Action(Keys.A);
        public static XNABaseLibrary.Action pl_right = new XNABaseLibrary.Action(Keys.D);
        public static XNABaseLibrary.Action pl_jump = new XNABaseLibrary.Action(Keys.Space);

        //PAUSE MENU
        public static XNABaseLibrary.Action pause = new XNABaseLibrary.Action(Keys.Escape);
    }
}
