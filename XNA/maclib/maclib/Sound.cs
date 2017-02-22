using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Audio;

namespace maclib
{
    public class Sound
    {
        #region variables

        protected SoundEffect _sound;
        public float _volume = 1f;
        public float _pitch = 0f;
        public float _pan = 0f;

        #endregion

        public Sound(SoundEffect sound)
        {
            _sound = sound;
        }

        public Sound(SoundEffect sound, float volume)
        {
            _sound = sound;
            _volume = volume;
        }

        public Sound(SoundEffect sound, float volume, float pitch, float pan)
        {
            _sound = sound;
            _volume = volume;
            _pitch = pitch;
            _pan = pan;
        }

        public void Update(GameTime gameTime)
        {
            _sound.Play(_volume, _pitch, _pan);
        }
    }
}