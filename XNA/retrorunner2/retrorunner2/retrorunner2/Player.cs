using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;
using maclib;

namespace retrorunner2
{
    class Player : Sprite
    {
        const float _gravity = 20f; //10
        float _friction = 0.2f; //0.02 slidey.
        enum Direction { LEFT, RIGHT };
        enum Movement { JUMP, WALK, RUN };
        Direction pl_dir = Direction.RIGHT;
        Direction pl_olddir;
        bool _isFalling = true;
        Vector2 _colOffset = new Vector2(1, 1);
        const int _maxVel = 50;

        public Player(Texture2D texture, Vector2 position, Point frameSize, Point currentFrame)
            : base(texture, position, frameSize, currentFrame)
        {
            _isNotMoving = false;
            _acceleration = new Vector2(0, 0);
        }

        public Player(Texture2D texture, Vector2 position, Point frameSize, Point currentFrame, Point hitbox)
            : base(texture, position, frameSize, currentFrame, hitbox)
        {
            _isNotMoving = false;
            _acceleration = new Vector2(0, 0);
        }

        public void Update(GameTime gameTime, List<Object> tiles, Camera camera)
        {

            //COLLISION DETECTION VERTICAL
            foreach (Object tile in tiles)
            {
                if (checkCollision(tile._hitbox, new Rectangle((int)(_hitbox.X), (int)(_hitbox.Y + _colOffset.Y + _velocity.Y), _hitbox.Width, _hitbox.Height)))
                {
                    if (tile._position.Y > _hitbox.Y) //Above Tile Collision
                    {
                        _isFalling = false;
                        _velocity.Y = 0;
                        _position.Y = tile._hitbox.Top - _frameSize.Y;
                        _hitbox.Y = tile._hitbox.Top - _hitbox.Height;
                        break;
                    }
                }
                if (checkCollision(tile._hitbox, new Rectangle((int)(_hitbox.X), (int)(_hitbox.Y - _colOffset.Y + _velocity.Y), _hitbox.Width, _hitbox.Height)))
                {
                    if (tile._position.Y < _hitbox.Y) //Underneath Tile Collision
                    {
                        _position.Y = tile._hitbox.Bottom + _colOffset.Y;
                        _hitbox.Y = tile._hitbox.Bottom + (_frameSize.Y - _hitbox.Height) + (int)_colOffset.Y;
                        _velocity.Y = 0;
                    }
                }
                else
                {
                    _isFalling = true;
                }
            }

            //UPDATING POSITION
            _position.Y = _position.Y + _velocity.Y;
            _hitbox.Y = _hitbox.Y + (int)_velocity.Y;

            //COLLISION DETECTION HORIZONTAL
            foreach (Object tile in tiles)
            {
                if (checkCollision(tile._hitbox, new Rectangle((int)(_hitbox.X + _colOffset.X + _velocity.X), (int)(_hitbox.Y), _hitbox.Width, _hitbox.Height)))
                {
                    if (tile._position.X > _hitbox.X) //To the Left of the Tile
                    {
                        _velocity.X = 0;
                        _position.X = tile._hitbox.Left - _frameSize.X - _colOffset.X;
                        _hitbox.X = tile._hitbox.Left - _hitbox.Width - (int)_colOffset.X;
                    }
                }
                if (checkCollision(tile._hitbox, new Rectangle((int)(_hitbox.X - _colOffset.X + _velocity.X), (int)(_hitbox.Y), _hitbox.Width, _hitbox.Height)))
                {
                    if (tile._position.X < _hitbox.X) //To the Right of the Tile
                    {
                        _velocity.X = 0;
                        _position.X = tile._hitbox.Right + _colOffset.X;
                        _hitbox.X = tile._hitbox.Left + (int)_colOffset.X;
                    }
                }
            }

            //CAP HORIZONTAL MOVEMENT VELOCITY
            if (_velocity.X > _maxVel)
                _velocity.X = _maxVel;
            else if (_velocity.X < -_maxVel)
                _velocity.X = -_maxVel;

            //UPDATING POSITION
            _position.X = _position.X + _velocity.X;

            //HORIZONTAL X-AXIS MOVEMENT
            if (KeyEvents.isKeyHeld(Controls.pl_left.getKey(), Game1.KS, Game1.oldKS)) //MOVING LEFT
            {
                _acceleration.X = 5;
                pl_dir = Direction.LEFT;
                this.Animate(new Point(1, 0), new Point(3, 0));
                _velocity.X = _velocity.X - _acceleration.X * (float)_dt;
            }
            else if (KeyEvents.isKeyHeld(Controls.pl_right.getKey(), Game1.KS, Game1.oldKS)) //MOVING RIGHT
            {
                _acceleration.X = 5;
                pl_dir = Direction.RIGHT;
                this.Animate(new Point(1, 0), new Point(3, 0));
                _velocity.X = _velocity.X + _acceleration.X * (float)_dt;
            }
            else //NOT APPLYING FORCE
            {
                //SURFACE FRICTION AND VELOCITY
                if (Math.Round(_velocity.X) > 0) //MOVING RIGHT
                {
                    _acceleration.X = _acceleration.X - _gravity * _friction;
                    if (_velocity.X + _acceleration.X * (float)_dt > 0) //add limit on suddenly gaining -ve velocity
                        _velocity.X = _velocity.X + _acceleration.X * (float)_dt;
                    else
                       _velocity.X = _velocity.X / (_gravity * _friction);
                    this.Animate(new Point(0, 0), new Point(1, 0));
                }
                else if (Math.Round(_velocity.X) < 0) //MOVING LEFT
                {
                    _acceleration.X = _acceleration.X - _gravity * _friction;
                    if (_velocity.X - _acceleration.X * (float)_dt < 0)
                        _velocity.X = _velocity.X - _acceleration.X * (float)_dt;
                    else
                        _velocity.X = _velocity.X / (_gravity * _friction);
                    this.Animate(new Point(0, 0), new Point(1, 0));
                }
                else if (Math.Round(_velocity.X) == 0)
                {
                    _velocity.X = 0;
                    this.Animate(new Point(0, 0), new Point(1, 0));
                }
            }

            //PLACING THIS WITHIN THE PREVIOUS ELSE STATEMENT WILL GIVE PRECEDENCE TO HORIZONTAL ANIMATIONS OVER JUMP
            if (_velocity.Y != 0) //If player is not at rest in the Y-dir, do the jump animation
            {
                this._currentFrame = new Point(3, 0);
                this.Animate(new Point(3, 0), new Point(4, 0));
            }

            //VERTICAL Y-AXIS MOVEMENT
            //DEFAULT PREVENTS MULTI-JUMP
            if (KeyEvents.isKeyPressed(Controls.pl_jump.getKey(), Game1.KS, Game1.oldKS) && !_isFalling)
            {
                //pl_mov = Movement.JUMP;
                _acceleration.Y = 150; //Applied Acceleration in the Y-dir for jump 90
                _velocity.Y = _velocity.Y - _acceleration.Y * (float)_dt;
            }
            else if (_acceleration.Y > -_gravity && _isFalling)
            {
                _acceleration.Y = _acceleration.Y - _gravity; //Gravity acting upon net acceleration
                _velocity.Y = _velocity.Y - _acceleration.Y * (float)_dt;
            }
            else if (_isFalling)
            {
                _acceleration.Y = -_gravity; //Cap fall acceleration to acceleration due to gravity
                _velocity.Y = _velocity.Y - _acceleration.Y * (float)_dt;
            }

            //DIRECTIONAL EFFECTS
            //NOTE TO SELF: Designed so when direction changes, velocity is forced to 0 for faster reaction times.
            if (pl_dir == Direction.RIGHT)
            {
                _spriteEffects = SpriteEffects.None;
            }
            else if (pl_dir == Direction.LEFT)
            {
                _spriteEffects = SpriteEffects.FlipHorizontally;
            }
            if (pl_olddir != pl_dir) //If last direction is not the same as new direction on last cycle
            {
                _velocity.X = 0;
            }

            ////ZOOM EFFECT BASED ON SPEED
            //if (((_maxVel - Math.Abs(_velocity.X / 5)) / _maxVel) > 0.75)
            //{
            //    Game1.camera2D._zoom = ((_maxVel - Math.Abs(_velocity.X / 5)) / _maxVel);

            //    //Readjust Y-pos of Camera based on Zoom
            //    Game1.camera2D._position = new Vector2(Game1.camera2D._position.X, -(Game1.w_Height - Game1.w_Height * Game1.camera2D._zoom));
            //}
            
            pl_olddir = pl_dir;
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

            if (Game1.dev)
            {
                Rectangle dev_BoundingBox = new Rectangle(_hitbox.X + (int)camera.X, _hitbox.Y + (int)camera.Y, _hitbox.Width, _hitbox.Height);
                spriteBatch.Draw(Game1.dev_RectTexture, dev_BoundingBox, Color.Red);
            }
        }
    }
}
