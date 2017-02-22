using UnityEngine;
using System.Collections;
using UnityEngine.SceneManagement;

namespace CapturedFlag.Engine
{
    /// <summary>
    /// Manages one shot sounds.
    /// </summary>
    public class SoundManager : MonoBehaviour
    {
        /// <summary>
        /// Maximum number of one shot sounds active at once.
        /// </summary>
        private const int MAX_POINT_SOURCES = 100;

        /// <summary>
        /// Object pool containing all one shot sound prefabs already instantiated.
        /// </summary>
        [HideInInspector]
        public Pool pool;

        /// <summary>
        /// One shot sound prefab, has directional control.
        /// </summary>
        public GameObject prefabSound;

        /// <summary>
        /// Sound manager instance, only one active at a time.
        /// </summary>
        public static SoundManager instance;

        public void Initialize()
        {
            if (pool == null)
            {
                var obj = new GameObject("PoolSound");
                obj.transform.parent = transform;
                pool = obj.AddComponent<Pool>();
                pool.prefab = prefabSound;
                pool.objectCount = MAX_POINT_SOURCES;
            }
        }

        private void OnLevelFinishedLoading(Scene scene, LoadSceneMode mode)
        {
            pool.Reset();
        }

        void Awake()
        {
            if (instance == null)
            {
                instance = this;
                DontDestroyOnLoad(this.gameObject);
                Initialize();
                SceneManager.sceneLoaded += OnLevelFinishedLoading;
            }
            else
            {
                Destroy(this.gameObject);
            }
        }

        public void OneShot(Sound sound)
        {
            StartCoroutine(WaitThenRecycle(sound));
        }

        private IEnumerator WaitThenRecycle(Sound sound)
        {
            //Wait Update
            yield return 0;

            for (;;)
            {
                if (sound != null)
                {
                    if (!sound.source.isPlaying)
                    {
                        break;
                    }
                    else
                    {
                        yield return 0;
                    }
                }
                else
                {
                    Debug.LogError("Error: Sound is null...");
                    break;
                }
            }

            if (sound != null)
                sound.gameObject.Recycle();
        }
    }
}