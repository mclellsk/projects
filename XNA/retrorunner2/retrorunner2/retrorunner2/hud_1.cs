using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using maclib;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;

namespace retrorunner2
{
    class hud_1 : HUD
    {
        Player player;

        public hud_1(Dictionary<string, SpriteFont> fonts, Player player)
            : base(fonts)
        {
            this.player = player;
        }

        public override void Update(GameTime gameTime)
        {
 	        base.Update(gameTime);
        }

        public override void Draw(GameTime gameTime, SpriteBatch spriteBatch)
        {
            Display = new Text("Velocity: " + player._velocity.ToString(), _fonts["Arial"], Color.White, new Vector2(0, 0), new Rectangle(0, 0, 200, 100));
            Display.Draw(spriteBatch);

            Display = new Text("Position: " + player._position.ToString(), _fonts["Arial"], Color.White, new Vector2(0, 10), new Rectangle(0, 0, 200, 100));
            Display.Draw(spriteBatch);

            Display = new Text("Acceleration: " + player._acceleration.ToString(), _fonts["Arial"], Color.White, new Vector2(0, 20), new Rectangle(0, 0, 200, 100));
            Display.Draw(spriteBatch);

            Display = new Text("Current Frame: " + player._currentFrame.ToString(), _fonts["Arial"], Color.White, new Vector2(0, 30), new Rectangle(0, 0, 200, 100));
            Display.Draw(spriteBatch);

            Display = new Text("Rectangle: " + player._hitbox.ToString(), _fonts["Arial"], Color.White, new Vector2(0, 40), new Rectangle(0, 0, 200, 100));
            Display.Draw(spriteBatch);
        }
    }
}
