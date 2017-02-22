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
    public class Button : Sprite
    {
        Cursor _cursor;
        Point _up, _down, _over;

        public Button(Texture2D texture, Vector2 position, Point frameSize, Point currentFrame, bool isPaused, Cursor cursor, Point up, Point down, Point over) : base(texture, position, frameSize, currentFrame, isPaused)
        {
            _cursor = cursor;
            _up = up;
            _down = down;
            _over = over;
        }

        //Checks to see if the button has been pressed by the mouse cursor,
        //where mouseCondition is the type of mouse event (click or held).
        public bool isDown(bool mouseCondition)
        {
            return (mouseCondition && checkCollision(_cursor._hitbox, this._hitbox));
        }

        public bool isOver()
        {
            return (checkCollision(_cursor._hitbox, this._hitbox));
        }

        public bool isUp()
        {
            return (!checkCollision(_cursor._hitbox, this._hitbox));
        }

        public void Update(GameTime gameTime, Cursor cursor, MouseState mouseState, MouseState oldMouseState)
        {
            _cursor = cursor;

            if (isUp())
            {
                Animate(_up, _up);
            }
            else if (isDown(_cursor.isLeftHeld(mouseState, oldMouseState)))
            {
                Animate(_down, _down);
            }
            else if (isOver())
            {
                Animate(_over, _over);
            }

            base.Update(gameTime);
        }

        //The position of the cursor on the button is checked, and the appropriate
        //button image is drawn. (1,0) means first row, second column, assuming that
        //up is stored in the 2nd column of the spritesheet for the button.
        //Change where needed.
        public override void Draw(GameTime gameTime, SpriteBatch spriteBatch)
        {
            base.Draw(gameTime, spriteBatch);
        }
    }
}
