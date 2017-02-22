using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using maclib;
using Microsoft.Xna.Framework.Graphics;
using Microsoft.Xna.Framework;

namespace retrorunner2
{
    class World
    {
        //A List of Levels(Dictionary of Objects)
        public Dictionary<string, Levels> mapList;

        //A List of the maps discovered so far that comprise the world (duplicate levels can exist in one world)
        public List<Levels> world = new List<Levels>();
        private tiling current, previous, future;
        public int _tileSize = 64;
        public int _curElement = 0;

        public class tiling
        {
            public List<Object> tiles = new List<Object>();
            public Levels _level;
            public int _tileSize, _offset;

            public tiling(Levels level, int tileSize, int offset)
            {
                _level = level;
                _tileSize = tileSize;
                //number of tiles before the first tile in the current segment
                _offset = offset;
                generateTiles();
            }

            void generateTiles()
            {
                for (int i = 0; i < _level.colorgrid.GetLength(0); i++)
                {
                    for (int j = 0; j < _level.colorgrid.GetLength(1); j++)
                    {
                        //DIRT
                        if (_level.colorgrid[i, j] == (new Color(0, 255, 0)))
                        {
                            tiles.Add(new Object(Game1.textures["ts_Dirt"], new Vector2((i + _offset) * _tileSize, j * _tileSize), new Point(64, 64), new Point(0, 1), true));
                        }
                        if (_level.colorgrid[i, j] == (new Color(0, 225, 0)))
                        {
                            tiles.Add(new Object(Game1.textures["ts_Dirt"], new Vector2((i + _offset) * _tileSize, j * _tileSize), new Point(64, 64), new Point(0, 0), true));
                        }
                    }
                }
            }

            public int getLevelPos()
            {
                return this._level._texture.Width;
            }
        }

        public World(Dictionary<string, Levels> mapList)
        {
            this.mapList = mapList;
            current = genLevel();
            future = genLevel();
        }

        tiling genLevel()
        {
            Random rand = new Random();
            int levelNum = rand.Next(mapList.Count);

            //Add next randomly generated piece of world
            world.Add(mapList.ElementAt(levelNum).Value);
            //Create a tiling object which will contain the data for the latest addition to the world
            return new tiling(mapList.ElementAt(levelNum).Value, _tileSize, calcPosOffset(world.Count));
        }

        public void Update(GameTime gameTime, Player player)
        {
            //If the player passes the current level on the right
            if (player._position.X > (current._offset + current.getLevelPos()) * _tileSize)
            {
                previous = current;
                current = future;
                //Element of generated world currently on
                _curElement += 1;
                if (world.Count-1 == _curElement)
                    future = genLevel();
                else
                    future = new tiling(world.ElementAt(_curElement + 1), _tileSize, calcPosOffset(_curElement));
            }
            if (player._position.X < (current._offset) * _tileSize)
            {
                //If the player is on the first part of the world, there is no previous data
                if (_curElement > 0)
                {
                    future = current;
                    current = previous;
                    //update which element is current
                    _curElement -= 1;
                    previous = new tiling(world.ElementAt(_curElement), _tileSize, calcPosOffset(_curElement));
                }
            }
        }

        int calcPosOffset(int element)
        {
            int posOffset = 0;
            for (int i = 0; i < world.Count; i++)
            {
                //gives total position offset for maps
                if (i != element - 1)
                    posOffset += (world[i]._texture.Width);
                else
                    break;
            }
            return posOffset;
        }

        public List<Object> masterTileList()
        {
            List<Object> temp = new List<Object>();

            if (previous != null)
                foreach (Object tile in previous.tiles)
                    temp.Add(tile);
            foreach (Object tile in current.tiles)
                temp.Add(tile);
            foreach (Object tile in future.tiles)
                temp.Add(tile);

            return temp;
        }
    }
}
