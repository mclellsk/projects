using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using maclib;
using Microsoft.Xna.Framework.Input;

namespace retrorunner2
{
    public class Controls
    {
        //PLAYER CONTROLS
        public static maclib.Action pl_left = new maclib.Action(Keys.A);
        public static maclib.Action pl_right = new maclib.Action(Keys.D);
        public static maclib.Action pl_jump = new maclib.Action(Keys.Space);

        //PAUSE MENU
        public static maclib.Action pause = new maclib.Action(Keys.Escape);
    }
}
