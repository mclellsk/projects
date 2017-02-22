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
    public class Cursor : Sprite
    {

        //Pass the mouse spritesheet, the mouse start position, the frame size, the frame that the spritesheet should be initialized to, and MouseState
        public Cursor(Texture2D texture, Vector2 position, Point frameSize, Point currentFrame, bool isPaused)
            : base(texture, position, frameSize, currentFrame, isPaused)
        {
            _hitbox = new Rectangle((int)_position.X, (int)_position.Y, 10, 10);
        }

        //Checks to see if Left Mouse Button is clicked.
        public bool isLeftClicked(MouseState _mouseState, MouseState _oldMouseState)
        {
            return (_mouseState.LeftButton == ButtonState.Released && _oldMouseState.LeftButton == ButtonState.Pressed);
        }

        //Checks to see if Left Mouse Button is held.
        public bool isLeftHeld(MouseState _mouseState, MouseState _oldMouseState)
        {
            return (_mouseState.LeftButton == ButtonState.Pressed && _oldMouseState.LeftButton == ButtonState.Pressed);
        }

        //Checks to see if Right Mouse Button is clicked.
        public bool isRightClicked(MouseState _mouseState, MouseState _oldMouseState)
        {
            return (_mouseState.RightButton == ButtonState.Released && _oldMouseState.RightButton == ButtonState.Pressed);
        }

        //Checks to see if Right Mouse Button is held.
        public bool isRightHeld(MouseState _mouseState, MouseState _oldMouseState)
        {
            return (_mouseState.RightButton == ButtonState.Pressed && _oldMouseState.RightButton == ButtonState.Pressed);
        }

        //Returns mouse coordinates
        public float msX(MouseState mouseState)
        {
            return mouseState.X;
        }

        public float msY(MouseState mouseState)
        {
            return mouseState.Y;
        }

        public void Update(GameTime gameTime, MouseState mouseState)
        {
            _position.X = msX(mouseState);
            _position.Y = msY(mouseState);

            base.Update(gameTime);
        }

        public override void Draw(GameTime gameTime, SpriteBatch spriteBatch)
        {
            base.Draw(gameTime, spriteBatch);
        }
    }
}
