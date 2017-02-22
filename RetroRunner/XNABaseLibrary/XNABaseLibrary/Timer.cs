using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Audio;
using Microsoft.Xna.Framework.Content;
using Microsoft.Xna.Framework.GamerServices;
using Microsoft.Xna.Framework.Graphics;
using Microsoft.Xna.Framework.Input;
using Microsoft.Xna.Framework.Media;

namespace XNABaseLibrary
{
    public class Timer
    {
        private float _timeInMS = 0;
        private float _elapsedTime = 0;

        public Timer()
        {
        }

        //Compares elapsed time to wait time, if elapsed time is greater than or equal to the wait time,
        //return the bool true to indicate the wait is over.
        public bool Wait(float waitTimeInMS, GameTime gameTime)
        {
            _timeInMS += gameTime.ElapsedGameTime.Milliseconds;

            if (_timeInMS >= waitTimeInMS)
            {
                _timeInMS = 0;
                return true;
            }
            else 
                return false;
        }

        //Needs to be declared in Update, allows for detection of how long the timer has been running.
        public void UpdateTimer(GameTime gameTime)
        {
            _elapsedTime += gameTime.ElapsedGameTime.Milliseconds;
        }

        //Returns value of current time elapsed since initialization of timer
        public float TimeElapsed()
        {
            return _elapsedTime;
        }
    }
}
