using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;
using Microsoft.Xna.Framework.Input;
using XNABaseLibrary;

namespace RetroRunner
{
    class GameStart : GameState
    {
        Player player1;

        //Each index of the list is another difficulty, Dicionary contains a (string, colorgrid) combination
        Dictionary<string, Levels> maps = new Dictionary<string, Levels>();

        Camera mainview;
        hud_1 hud;
        World world;

        List<Object> masterList = new List<Object>();

        public GameStart()
            : base()
        {
            player1 = new Player(Game1.textures["Runner"], new Vector2(128,128), new Point(77, 100), new Point(0, 0), new Point(50,70)); //new Point(50,100) hitbox

            mainview = new Camera(Vector2.Zero, player1, Game1.w_Width/10, Game1.w_Height/2);
            hud = new hud_1(Game1.fonts, player1);

            //ADD LEVELS TO LIST OF MAPS
            //maps.Add("lvl_e1", new Levels(Game1.textures["lvl_e1"], Levels.DIFF.EASY));
            //maps.Add("lvl_e2", new Levels(Game1.textures["lvl_e2"], Levels.DIFF.EASY));
            maps.Add("lvl_DEV2", new Levels(Game1.textures["lvl_DEV2"], Levels.DIFF.EASY));

            //INITIALIZE WORLD
            world = new World(maps);
        }

        //UPDATE LOOP
        public override void Update(Microsoft.Xna.Framework.GameTime gameTime)
        {
            world.Update(gameTime, player1);
            masterList = world.masterTileList();

            player1.Update(gameTime, masterList, mainview);
            for (int i = 0; i < masterList.Count; i++)
            {
                masterList[i].Update(gameTime);
            }
            mainview.Update(gameTime);
            base.Update(gameTime);
        }

        //DRAW LOOP
        public override void Draw(GameTime gameTime, SpriteBatch spriteBatch, GraphicsDevice graphicsDevice)
        {
            spriteBatch.Begin(SpriteSortMode.BackToFront, BlendState.AlphaBlend, null, null, null, null, Game1.camera2D.getTransform(graphicsDevice));
            player1.Draw(gameTime, spriteBatch, mainview.monitorview);
            for (int i = 0; i < masterList.Count; i++)
            {
                masterList[i].Draw(gameTime, spriteBatch, mainview.monitorview);
            }
            spriteBatch.End();

            spriteBatch.Begin();
            hud.Draw(gameTime, spriteBatch);
            base.Draw(gameTime, spriteBatch, graphicsDevice);
        }
    }
}
