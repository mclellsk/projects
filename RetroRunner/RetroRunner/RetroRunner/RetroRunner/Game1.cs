using System;
using System.Collections.Generic;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;
using Microsoft.Xna.Framework.Input;
using XNABaseLibrary;

namespace RetroRunner
{
    public class Game1 : Microsoft.Xna.Framework.Game
    {
        GraphicsDeviceManager graphics;
        SpriteBatch spriteBatch;
        public static Camera2D camera2D = new Camera2D(0, 1, Vector2.Zero);

        //TEXTURES AND FONTS AND SOUNDS
        public static Dictionary<string, Texture2D> textures = new Dictionary<string,Texture2D>();
        public static Dictionary<string, SpriteFont> fonts = new Dictionary<string, SpriteFont>();
        public static Texture2D dev_RectTexture;

        //STATE MANAGER AND STATES
        public static StateManager stateManager = new StateManager();
        public static Dictionary<string, GameState> stateList = new Dictionary<string, GameState>();

        MainMenu state_MainMenu;
        GameStart state_GameStart;

        public static Cursor cursor;
        public static MouseState MS, oldMS;
        public static KeyboardState KS, oldKS;

        public const int w_Height = 480, w_Width = 720;

        bool init = false;
        public static bool dev = false;

        public Game1()
        {
            graphics = new GraphicsDeviceManager(this);
            Content.RootDirectory = "Content";

            graphics.PreferredBackBufferWidth = w_Width;
            graphics.PreferredBackBufferHeight = w_Height;  
        }

        protected override void Initialize()
        {
            base.Initialize();
        }

        protected override void LoadContent()
        {
            spriteBatch = new SpriteBatch(GraphicsDevice);

            //LOAD TEXTURES
            textures.Add("Cursor1", Content.Load<Texture2D>("cursor"));
            textures.Add("ts_Dirt", Content.Load<Texture2D>("dirt_tileset"));
            textures.Add("Runner", Content.Load<Texture2D>("runner"));
            textures.Add("Title", Content.Load<Texture2D>("title"));
            textures.Add("btn_Start", Content.Load<Texture2D>("btn_start"));
            dev_RectTexture = new Texture2D(this.GraphicsDevice, 1, 1);
            dev_RectTexture.SetData(new Color[]{Color.White});

            //LOAD LEVEL PNGS
            textures.Add("lvl_DEV", Content.Load<Texture2D>("level_dev"));
            textures.Add("lvl_DEV2", Content.Load<Texture2D>("level_dev2"));
            textures.Add("lvl_e1", Content.Load<Texture2D>("level_e1"));
            textures.Add("lvl_e2", Content.Load<Texture2D>("level_e2"));

            //LOAD SOUNDS

            //LOAD FONTS
            fonts.Add("Arial", Content.Load<SpriteFont>("Arial"));

            //LOAD STATES
            stateList.Add("st_MainMenu", state_MainMenu = new MainMenu());
            stateList.Add("st_GameStart", state_GameStart = new GameStart());

            cursor = new Cursor(textures["Cursor1"],Vector2.Zero,new Point(32,32),Point.Zero,false);
        }

        protected override void UnloadContent()
        {
        }

        protected override void Update(GameTime gameTime)
        {
            MS = Mouse.GetState();
            KS = Keyboard.GetState();

            cursor.Update(gameTime, MS);

            //INITIAL STATE
            if (!init)
            {
                stateManager.pushStack(stateList["st_MainMenu"]);
                init = true;
            }

            //UPDATE CURRENT STATE
            stateManager.loadStack().Update(gameTime);

            base.Update(gameTime);

            oldMS = MS;
            oldKS = KS;
        }

        protected override void Draw(GameTime gameTime)
        {
            GraphicsDevice.Clear(Color.CornflowerBlue);

            //DRAW CURRENT STATE
            stateManager.loadStack().Draw(gameTime, spriteBatch, GraphicsDevice);
            cursor.Draw(gameTime, spriteBatch);

            spriteBatch.End();

            base.Draw(gameTime);
        }
    }
}
