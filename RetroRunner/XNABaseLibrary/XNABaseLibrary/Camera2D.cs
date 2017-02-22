using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;

namespace XNABaseLibrary
{
    public class Camera2D
    {
        public float _rotate, _zoom;
        public Matrix _transform;
        public Vector2 _position;

        public Camera2D(float rotate, float zoom, Vector2 pos)
        {
            _rotate = rotate;
            _zoom = zoom;
            _position = pos;
        }

        public void Move(Vector2 delta)
        {
            _position += delta;
        }

        public Matrix getTransform(GraphicsDevice graphicsDevice)
        {
            _transform = Matrix.CreateTranslation(new Vector3(-_position.X, -_position.Y, 0)) *
            Matrix.CreateRotationZ(_rotate) * Matrix.CreateScale(new Vector3(_zoom, _zoom, 1)) *
            Matrix.CreateTranslation(new Vector3(0, 0, 0));
            
            return _transform;
        }
    }
}
