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

namespace maclib
{
    public abstract class HUD
    {
        public Dictionary<String, SpriteFont> _fonts;
        public Text Display;

        public HUD(Dictionary<String, SpriteFont> fonts)
        {
            _fonts = fonts;
        }

        public virtual void Update(GameTime gameTime)
        {
        }

        public virtual void Draw(GameTime gameTime, SpriteBatch spriteBatch)
        {
            /*
            Display = new Text("HP: " + health, _fonts[0], Color.White, new Vector2(0, 0), new Rectangle(0, 0, 200, 100));
            Display.Draw(spriteBatch);

            Display = new Text("Ammo: " + ammo, _fonts[0], Color.White, new Vector2(0, 20), new Rectangle(0, 0, 200, 100));
            Display.Draw(spriteBatch);
             */
            //REPLACE ALL THIS WITH SOME DEFAULT DEVELOPER TOOLS (i.e. Position displays, speed, fps, hitboxes, etc.)
        }
    }
}
