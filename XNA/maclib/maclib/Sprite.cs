using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Audio;
using Microsoft.Xna.Framework.Content;
using Microsoft.Xna.Framework.GamerServices;
using Microsoft.Xna.Framework.Graphics;
using Microsoft.Xna.Framework.Input;
using Microsoft.Xna.Framework.Media;

namespace maclib
{
    public abstract class Sprite
    {
        public Texture2D _texture;
        public Vector2 _velocity = Vector2.Zero;
        public Vector2 _acceleration = Vector2.Zero;
        public Vector2 _position = Vector2.Zero;
        public Vector2 _screenPosition = Vector2.Zero;
        protected Point _sheetSize = Point.Zero;
        public  Point _frameSize;
        public Point _currentFrame;
        public Vector2 _scale = Vector2.One;
        public Vector2 _origin = Vector2.Zero;
        protected const int _defaultMPF = 50;
        protected float _millisecondsPerFrame;
        protected float _timeSinceLastFrame = 0;
        protected int _collisionOffset = 0;
        public float _depth = 0f;
        public float _rotationalVelocity = 0f;
        public float _rotation = 0f;
        public bool _isVisible = true;
        public bool _isNotMoving = false;
        public SpriteEffects _spriteEffects = SpriteEffects.None;
        public Color _color = Color.White;
        public Rectangle _hitbox = Rectangle.Empty;
        public Point _start = Point.Zero;
        public Point _end;
        public double _dt;
        public Point _hitboxDim;

        public Sprite(Texture2D texture, Vector2 position, Point frameSize, Point currentFrame)
        {
            _texture = texture;
            _position = position;
            _frameSize = frameSize;
            _sheetSize = new Point(texture.Width / frameSize.X, texture.Height / frameSize.Y);
            _end = _sheetSize;
            _currentFrame = currentFrame;
            _millisecondsPerFrame = _defaultMPF;
            _hitboxDim = frameSize;
            _hitbox = new Rectangle((int)_position.X, (int)_position.Y, (int)_frameSize.X, (int)_frameSize.Y);
        }

        public Sprite(Texture2D texture, Vector2 position, Point frameSize, Point currentFrame, bool isPaused)
        {
            _texture = texture;
            _position = position;
            _frameSize = frameSize;
            _sheetSize = new Point(texture.Width / frameSize.X, texture.Height / frameSize.Y);
            _end = _sheetSize;
            _currentFrame = currentFrame;
            _isNotMoving = isPaused;
            _millisecondsPerFrame = _defaultMPF;
            _hitboxDim = frameSize;
            _hitbox = new Rectangle((int)_position.X, (int)_position.Y, (int)_frameSize.X, (int)_frameSize.Y);
        }

        public Sprite(Texture2D texture, Vector2 position, Point frameSize, Point currentFrame, int ms, bool isPaused)
        {
            _texture = texture;
            _position = position;
            _frameSize = frameSize;
            _sheetSize = new Point(texture.Width/frameSize.X, texture.Height/frameSize.Y);
            _end = _sheetSize;
            _currentFrame = currentFrame;
            _isNotMoving = isPaused;
            _millisecondsPerFrame = ms;
            _hitboxDim = frameSize;
            _hitbox = new Rectangle((int)_position.X, (int)_position.Y, (int)_frameSize.X, (int)_frameSize.Y);
        }

		public Sprite(Texture2D texture, Vector2 position, Point frameSize, Point currentFrame, Point Hitbox)
        {
            _texture = texture;
            _position = position;
            _frameSize = frameSize;
            _sheetSize = new Point(texture.Width / frameSize.X, texture.Height / frameSize.Y);
            _end = _sheetSize;
            _currentFrame = currentFrame;
            _millisecondsPerFrame = _defaultMPF;
            _hitboxDim = Hitbox;
            _hitbox = new Rectangle((int)_position.X, (int)_position.Y, (int)_hitboxDim.X, (int)_hitboxDim.Y);
        }

        public Sprite(Texture2D texture, Vector2 position, Point frameSize, Point currentFrame, bool isPaused, Point Hitbox)
        {
            _texture = texture;
            _position = position;
            _frameSize = frameSize;
            _sheetSize = new Point(texture.Width / frameSize.X, texture.Height / frameSize.Y);
            _end = _sheetSize;
            _currentFrame = currentFrame;
            _isNotMoving = isPaused;
            _millisecondsPerFrame = _defaultMPF;
            _hitboxDim = Hitbox;
            _hitbox = new Rectangle((int)_position.X, (int)_position.Y, (int)_hitboxDim.X, (int)_hitboxDim.Y);
        }

        public Sprite(Texture2D texture, Vector2 position, Point frameSize, Point currentFrame, int ms, bool isPaused, Point Hitbox)
        {
            _texture = texture;
            _position = position;
            _frameSize = frameSize;
            _sheetSize = new Point(texture.Width/frameSize.X, texture.Height/frameSize.Y);
            _end = _sheetSize;
            _currentFrame = currentFrame;
            _isNotMoving = isPaused;
            _millisecondsPerFrame = ms;
            _hitboxDim = Hitbox;
            _hitbox = new Rectangle((int)_position.X, (int)_position.Y, (int)_hitboxDim.X, (int)_hitboxDim.Y);
        }
		
        public virtual void Update(GameTime gameTime)
        {
            _dt = gameTime.ElapsedGameTime.TotalSeconds;

            if (!_isNotMoving)
            {
                _timeSinceLastFrame += gameTime.ElapsedGameTime.Milliseconds;
                if (_timeSinceLastFrame > _millisecondsPerFrame)
                {
                    _timeSinceLastFrame -= _millisecondsPerFrame;

                    ++_currentFrame.X;
                    if (_currentFrame.X >= _end.X)
                    {
                        _currentFrame.X = _start.X;
                        ++_currentFrame.Y;

                        if (_currentFrame.Y >= _end.Y)
                            _currentFrame.Y = _start.Y;
                    }
                }
            }
            _hitbox = new Rectangle((int)_position.X + ((_frameSize.X - _hitbox.Width) / 2), (int)_position.Y + (_frameSize.Y - _hitbox.Height), (int)_hitboxDim.X, (int)_hitboxDim.Y);
        }

        public virtual void Draw(GameTime gameTime, SpriteBatch spriteBatch)
        {
            /*
            _screenPosition.X = _position.X + cameraView.X;
            _screenPosition.Y = _position.Y + cameraView.Y;
             */

            if (_isVisible)
            {
                Rectangle source = new Rectangle((_currentFrame.X * _frameSize.X), (_currentFrame.Y * _frameSize.Y), _frameSize.X, _frameSize.Y);
                spriteBatch.Draw(_texture, _position, source, _color, _rotation, _origin, _scale, _spriteEffects, _depth);
            }
        }

        public void Animate(Point start, Point end)
        {
            _start = start;
            _end = end;
        }

        //This does not belong here. Move it at some point.
        public static bool checkCollision(Rectangle one, Rectangle two)
        {
            return (one.Intersects(two));
        }
    }
}
