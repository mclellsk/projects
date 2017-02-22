using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using XNABaseLibrary;
using Microsoft.Xna.Framework.Graphics;
using Microsoft.Xna.Framework;

namespace RetroRunner
{
    public class Object : XNABaseLibrary.Sprite
    {
        public Object(Texture2D texture, Vector2 position, Point frameSize, Point currentFrame, Point hitbox)
            : base(texture, position, frameSize, currentFrame, hitbox)
        {
        }

        public Object(Texture2D texture, Vector2 position, Point frameSize, Point currentFrame, bool isPaused)
            : base(texture, position, frameSize, currentFrame, isPaused)
        {
        }

        public override void Update(GameTime gameTime)
        {
            base.Update(gameTime);
        }

        public void Draw(GameTime gameTime, SpriteBatch spriteBatch, Vector2 camera)
        {
            _screenPosition.X = _position.X + camera.X;
            _screenPosition.Y = _position.Y + camera.Y;

            if (_isVisible)
            {
                Rectangle source = new Rectangle((_currentFrame.X * _frameSize.X), (_currentFrame.Y * _frameSize.Y), _frameSize.X, _frameSize.Y);
                spriteBatch.Draw(_texture, _screenPosition, source, _color, _rotation, _origin, _scale, _spriteEffects, _depth);
            }
        }
    }
}
