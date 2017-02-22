using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;

namespace maclib
{
    public class PNGReader
    {
        protected Texture2D _map;
        public Color[,] _colorgrid;

        public PNGReader(Texture2D map)
        {
            _map = map;
            _colorgrid = ColorArray(_map);
        }

        private Color[,] ColorArray(Texture2D map)
        {
            //Copies texture data into an array [area] size, storing all data
            //in one dimension.
            Color[] color1D = new Color[map.Width * map.Height];
            map.GetData(color1D);

            //For convenience we change the array into a 2D array.
            Color[,] color2D = new Color[map.Width, map.Height];
            for (int i = 0; i < map.Width; i++)
                for (int j = 0; j < map.Height; j++)
                {
                    color2D[i, j] = color1D[i + j * (map.Width)];
                }
            return color2D;
        }
    }
}
