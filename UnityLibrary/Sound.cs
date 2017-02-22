using UnityEngine;
using System.Collections;
using System.Collections.Generic;

namespace CapturedFlag.Engine
{
    /// <summary>
    /// Individual sounds and general sound types are controlled by this class.
    /// </summary>
    [RequireComponent(typeof(AudioSource))]
    public class Sound : MonoBehaviour
    {
        private static readonly float MIN_DISTANCE = 10000f;

        public AudioSource source;

        /// <summary>
        /// Available sound types.
        /// </summary>
        public enum SoundType
        {
            MUSIC,
            SFX
        };

        /// <summary>
        /// Specific sound type for the instance.
        /// </summary>
        public SoundType type = SoundType.SFX;

        /// <summary>
        /// Sound properties for specific sound types.
        /// </summary>
        public class SoundInfo
        {
            /// <summary>
            /// Volume level multiplier for all instances of the specific sound type.
            /// </summary>
            private float _volume;

            /// <summary>
            /// Volume changed callback.
            /// </summary>
            public event System.Action OnVolumeChange;

            public float Volume
            {
                set
                {
                    _volume = value;

                    if (OnVolumeChange != null)
                        OnVolumeChange();
                }
                get
                {
                    return _volume;
                }
            }

            public SoundInfo(float volume)
            {
                _volume = volume;
            }
        }

        /// <summary>
        /// Dictionary of sound properties for each specific sound type.
        /// </summary>
        public static Dictionary<SoundType, SoundInfo> volumeInfo = new Dictionary<SoundType, SoundInfo>()
        {
            { SoundType.MUSIC, new SoundInfo(1f) },
            { SoundType.SFX, new SoundInfo(1f) }
        };

        /// <summary>
        /// Master volume changed callback.
        /// </summary>
        public static event System.Action OnMasterVolumeChanged;

        /// <summary>
        /// Master volume for all sounds.
        /// </summary>
        private static float _masterVolume = 1f;

        /// <summary>
        /// Master volume property for all sounds with change callback.
        /// </summary>
        public static float MasterVolume
        {
            set
            {
                _masterVolume = value;
                if (OnMasterVolumeChanged != null)
                    OnMasterVolumeChanged();
            }
            get
            {
                return _masterVolume;
            }
        }

        /// <summary>
        /// Base volume for individual instance of sound.
        /// </summary>
        public float baseVolume = 1f;

        /// <summary>
        /// AudioSource volume level controller.
        /// </summary>
        public float Volume
        {
            get
            {
                return source.volume;
            }
            set
            {
                baseVolume = value;
                source.volume = baseVolume * MasterVolume * volumeInfo[type].Volume;
            }
        }

        /// <summary>
        /// Update volume of specific sound instance whenever a change in volume occurs (master, specific or base).
        /// </summary>
        private void VolumeChange()
        {
            Volume = baseVolume;
        }

        /// <summary>
        /// Coroutine to play sound on a fixed loop.
        /// </summary>
        private Coroutine _cPlay;

        private void Awake()
        {
            var v = volumeInfo[type];
            if (v != null)
            {
                v.OnVolumeChange += VolumeChange;
            }

            OnMasterVolumeChanged += VolumeChange;

            //Initialize the volume
            VolumeChange();
        }

        private void OnDestroy()
        {
            var v = volumeInfo[type];
            if (v != null)
            {
                v.OnVolumeChange -= VolumeChange;
            }
        }

        private void OnDisable()
        {
            _cPlay = null;
        }

        public void SetSound(AudioClip clip, float volume = 1f, SoundType type = SoundType.SFX, float minDistance = 20f, float maxDistance = 150f, bool loop = false)
        {
            Stop();
            this.type = type;
            source.clip = clip;
            source.loop = loop;
            source.maxDistance = maxDistance;
            source.minDistance = minDistance;
            Volume = volume;
        }

        /// <summary>
        /// Stop looped sound.
        /// </summary>
        public void Stop()
        {
            if (_cPlay != null)
            {
                StopCoroutine(_cPlay);
                _cPlay = null;
            }

            source.Stop();
        }

        /// <summary>
        /// Play sound at a specific starting time in the audio source.
        /// </summary>
        /// <param name="timeStart">Time to start sound in playback.</param>
        public void Play(int timeStart = 0)
        {
            Stop();
            source.timeSamples = timeStart;
            source.Play();
        }

        /// <summary>
        /// Play sound at specific starting time in terms of percentage of the total playback time.
        /// </summary>
        /// <param name="timeStartPercent">Percentage into the playback before starting.</param>
        public void Play(float timeStartPercent)
        {
            Stop();
            source.timeSamples = (int)(timeStartPercent * source.clip.samples);
            source.Play();
        }

        /// <summary>
        /// Play sound at specific start time until end time in playback for a specific number of loops.
        /// </summary>
        /// <param name="timeStart">Start time in playback.</param>
        /// <param name="timeEnd">End time in playback.</param>
        /// <param name="loops">Number of loops to play.</param>
        public void Play(int timeStart, int timeEnd, int loops)
        {
            Stop();
            _cPlay = StartCoroutine(PlaySoundUntil(timeStart, timeEnd, loops));
        }

        /// <summary>
        /// Play sound at specific start time until end time expressed as a percent of total playback time,
        /// played for specific number of loops.
        /// </summary>
        /// <param name="timeStartPercent">Start time as a percent of total playback.</param>
        /// <param name="timeEndPercent">End time as a percent of total playback.</param>
        /// <param name="loops">Number of loops to play.</param>
        public void Play(float timeStartPercent, float timeEndPercent, int loops)
        {
            Stop();
            _cPlay = StartCoroutine(PlaySoundUntil((int)(timeStartPercent * source.clip.samples), (int)(timeEndPercent * source.clip.samples), loops));
        }

        /// <summary>
        /// One shot plays an audio clip from the source with no way to interrupt the audio. Volume controls
        /// have no effect on the sound once it begins to play.
        /// </summary>
        public void PlayOneShot(AudioClip clip)
        {
            source.PlayOneShot(clip, Volume);
        }

        /// <summary>
        /// Volume controls have no effect on the sound once it begins to play. Does not support 3D spatial sound.
        /// </summary>
        /// <param name="clip"></param>
        /// <param name="position"></param>
        public static void PlayAtPoint(AudioClip clip, Vector3 position, float volume, SoundType type)
        {
            //New audiosources (such as the ones created using PlayClipAtPoint) are queued when 
            //Time.timeScale is 0. In order to work around this, the Time.timeScale must be toggled 
            //on before creating a new audiosource, and then toggled back off if necessary.

            var timeScale = Time.timeScale;
            if (timeScale == 0f)
            {
                Time.timeScale = 1f;
            }

            var tempVolume = volume * MasterVolume * volumeInfo[type].Volume;
            AudioSource.PlayClipAtPoint(clip, position, tempVolume);

            Time.timeScale = timeScale;
        }

        /// <summary>
        /// Behaves similarly to PlayAtPoint, but supports 3D spatial sound. Retrieves unused audiosource from pool,
        /// plays sound at specific position, and then recycles object when done.
        /// </summary>
        /// <returns></returns>
        public static GameObject PlayAtPoint3D(AudioClip clip, Vector3 position, float volume, SoundType type, float minDistance = 20f, float maxDistance = 150f, Transform parent = null)
        {
            var soundObj = SoundManager.instance.pool.GetObject();
            if (soundObj != null)
            {
                soundObj.SetActive(true);
                soundObj.transform.position = position;
                if (parent != null)
                    soundObj.transform.parent = parent;
                else
                    soundObj.transform.parent = SoundManager.instance.pool.transform;
                var sound = soundObj.GetComponent<Sound>();
                sound.source.spatialBlend = 1.0f;
                sound.SetSound(clip, volume, type, minDistance, maxDistance);
                sound.Play();
                SoundManager.instance.OneShot(sound);
            }
            return soundObj;
        }

        /// <summary>
        /// Plays a sound at the position of the audio listener, adjusts the distance sound can be heard before experiencing fall-off
        /// to a large value so that when the listener moves it experiences no fall-off. Suggested use is for sounds that alert the user or 
        /// are related to UI feedback.
        /// </summary>
        /// <param name="clip"></param>
        /// <param name="volume"></param>
        /// <param name="type"></param>
        /// <returns></returns>
        public static GameObject PlaySound(AudioClip clip, float volume, SoundType type)
        {
            var listener = FindObjectOfType<AudioListener>();
            var obj = PlayAtPoint3D(clip, listener.transform.position, volume, type, MIN_DISTANCE, MIN_DISTANCE + 1f);
            obj.GetComponent<Sound>().source.spatialBlend = 0f;
            return obj;
        }

        /// <summary>
        /// Will play audiosource from timeStart sample value to timeEnd sample value for specified
        /// number of loops. If loops is less than 0, the sound is repeated until manually stopped.
        /// </summary>
        /// <param name="timeStart"></param>
        /// <param name="timeEnd"></param>
        /// <param name="loops"></param>
        /// <returns></returns>
        private IEnumerator PlaySoundUntil(int timeStart, int timeEnd, int loops)
        {
            for (;;)
            {
                source.timeSamples = timeStart;
                source.Play();

                for (;;)
                {
                    if (source.timeSamples < timeEnd)
                    {
                        yield return new WaitForEndOfFrame();
                    }
                    else
                    {
                        source.Stop();
                        break;
                    }
                }

                if (loops > 0)
                {
                    loops--;
                }
                else if (loops == 0)
                {
                    break;
                }
            }

            yield return 0;
        }
    }
}