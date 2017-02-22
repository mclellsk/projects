using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;
using maclib;

namespace maclib
{
    public class Camera
    {

        public Vector2 _cameraPosition = Vector2.Zero;
        public Vector2 _cameraCenter = new Vector2(400, 240);
        public bool _isFollowingSprite = true;
        public Sprite _spriteFocus;
        public Vector2 _acceleration = new Vector2(1000, 0);
        public Vector2 _velocity = Vector2.Zero;
        protected float _timeSinceLastFrame = 0;
        public Vector2 monitorview;
        public bool _trackVMov = true;
        protected float _zoom, _rotation;
        public Matrix _transform;

        public Camera(Vector2 position, Sprite sprite, int screenwidth, int screenheight)
        {
            _cameraPosition = position;
            _spriteFocus = sprite;
            _cameraCenter = new Vector2(screenwidth, screenheight);
        }

        public Camera()
        {
        }

        public void Update(GameTime gameTime)
        {
            if (_isFollowingSprite)
            {
                monitorview.X = _cameraCenter.X - _spriteFocus._position.X;
                if (_trackVMov)
                    monitorview.Y = _cameraCenter.Y - _spriteFocus._position.Y;
            }
        }

        //Focuses camera to center on a specified sprite.
        public void followSprite(Sprite sprite)
        {
            _spriteFocus = sprite;
        }

        //Moves camera from start vector, to end vector by increment per speedms.
        public void panView(GameTime gameTime, Vector2 end, float speedms, Point increment)
        {
            _isFollowingSprite = false;
            _timeSinceLastFrame += gameTime.ElapsedGameTime.Milliseconds;
            if (_timeSinceLastFrame > speedms)
            {
                if (_cameraPosition.X != end.X)
                {
                    if (_cameraPosition.X > end.X)
                        _cameraPosition.X -= increment.X;
                    else
                        _cameraPosition.X += increment.X;
                }

                if (_cameraPosition.Y != end.Y)
                {
                    if (_cameraPosition.Y > end.Y)
                        _cameraPosition.Y -= increment.Y;
                    else
                        _cameraPosition.Y += increment.Y;
                }

                _timeSinceLastFrame = 0;
            }
        }
    }
}
