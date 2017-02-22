using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;
using maclib;

namespace retrorunner2
{
    class Sprite : maclib.Sprite
    {
        public Sprite(Texture2D texture, Vector2 position, Point frameSize, Point currentFrame)
            : base(texture, position, frameSize, currentFrame)
        {
        }

        public Sprite(Texture2D texture, Vector2 position, Point frameSize, Point currentFrame, Point hitbox)
            : base(texture, position, frameSize, currentFrame, hitbox)
        {
        }

        public override void Update(GameTime gameTime)
        {
            base.Update(gameTime);
        }

        public override void Draw(GameTime gameTime, SpriteBatch spriteBatch)
        {
            base.Draw(gameTime, spriteBatch);
        }
    }
}
