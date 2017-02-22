using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;
using XNABaseLibrary;

namespace RetroRunner
{
    public class Levels
    {
        public enum DIFF { EASY, MEDIUM, HARD };
        public DIFF difficulty;
        public Color[,] colorgrid;
        public Texture2D _texture;

        public Levels(Texture2D map_png, DIFF difficulty)
        {
            _texture = map_png;
            colorgrid = new PNGReader(map_png)._colorgrid;
            this.difficulty = difficulty;
        }
    }
}
