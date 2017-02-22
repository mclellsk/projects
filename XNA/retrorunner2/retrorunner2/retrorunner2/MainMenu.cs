using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;
using Microsoft.Xna.Framework.Input;
using maclib;

namespace retrorunner2
{
    class MainMenu : GameState
    {
        Sprite title;
        Button btn_start;
        
        public MainMenu()
            : base()
        {
            title = new Sprite(Game1.textures["Title"], new Vector2(240, 50), new Point(240, 100), new Point(0, 0));
            btn_start = new Button(Game1.textures["btn_Start"], new Vector2(240, 200), new Point(240, 25), new Point(0, 0), false, Game1.cursor, new Point(0, 0), new Point(2, 0), new Point(1, 0)); 
        }

        //UPDATE LOOP
        public override void Update(Microsoft.Xna.Framework.GameTime gameTime)
        {
            title.Update(gameTime);
            btn_start.Update(gameTime, Game1.cursor, Game1.MS, Game1.oldMS);

            if (btn_start.isDown(Game1.cursor.isLeftClicked(Game1.MS, Game1.oldMS)))
            {
                Game1.stateManager.popStack();
                Game1.stateManager.pushStack(Game1.stateList["st_GameStart"]);
            }
            
            base.Update(gameTime);
        }

        //DRAW LOOP
        public override void Draw(GameTime gameTime, SpriteBatch spriteBatch, GraphicsDevice graphicsDevice)
        {
            spriteBatch.Begin();
            title.Draw(gameTime, spriteBatch);
            btn_start.Draw(gameTime, spriteBatch);
            base.Draw(gameTime, spriteBatch, graphicsDevice);
        }
    }
}
