using UnityEngine;
using System.Collections;
using System.Collections.Generic;

namespace CapturedFlag.Engine
{
    public class Factory : Actor
    {
        /// <summary>
        /// The current number of spawns since the factory was created (resets when limit is reached)
        /// </summary>
        [HideInInspector]
        [SerializeField]
        protected int currentSpawn = 0;
        /// <summary>
        /// Total number of spawns before depletion
        /// </summary>
        public int totalSpawn = 0;
        /// <summary>
        /// Maximum number of active objects at once.
        /// </summary>
        public int maxActiveSpawn = 0;

        /// <summary>
        /// Determines if the factory is depleted, based on totalSpawn.
        /// </summary>
        private bool _isDepleted = false;

        /// <summary>
        /// Initialize the object before activeSelf is true.
        /// </summary>
        public event EventCallbacks.GameObjectHandler OnInitialize;
        /// <summary>
        /// Fired right after the factory object is initially activated.
        /// </summary>
        public event EventCallbacks.GameObjectHandler OnSpawn;

        /// <summary>
        /// A pool of objects to spawn from.
        /// </summary>
        public Pool pool;

        /// <summary>
        /// The minimum time to wait between spawns.
        /// </summary>
        public float minTimeToWait = 0f;
        /// <summary>
        /// The maximum time to wait between spawns.
        /// </summary>
        public float maxTimeToWait = 1f;

        /// <summary>
        /// The range for x coordinate spawn offset.
        /// </summary>
        public Vector2 xOffset = Vector2.zero;
        /// <summary>
        /// The range for y coordinate spawn offset.
        /// </summary>
        public Vector2 yOffset = Vector2.zero;
        /// <summary>
        /// The range for z coordinate spawn offset.
        /// </summary>
        public Vector2 zOffset = Vector2.zero;

        /// <summary>
        /// A list of all possible spawn positions.
        /// </summary>
        public List<Transform> spawnPositions = new List<Transform>();

        /// <summary>
        /// Determines if the factory spawns forever or if it follows the specified limit.
        /// </summary>
        public bool isRepeating = true;
        /// <summary>
        /// Determines if spawning is paused.
        /// </summary>
        public bool isPaused = false;
        /// <summary>
        /// Determines if the factory starts spawning when enabled.
        /// </summary>
        public bool isAuto = true;

        /// <summary>
        /// List of all active objects spawned from this factory.
        /// </summary>
        public List<GameObject> activeObjects = new List<GameObject>();

        /// <summary>
        /// Current spawn number.
        /// </summary>
        public int CurrentSpawn
        {
            get { return currentSpawn; }
        }
        /// <summary>
        /// The total number of active objects
        /// </summary>
        public int ActiveSpawn
        {
            get
            {
                return activeObjects.Count;
            }
        }

        private Coroutine _cSpawning;

        public override void OnReEnable()
        {
            base.OnReEnable();

            if (isAuto)
                StartFactory();
        }

        public override void Start()
        {
            base.Start();

            if (isAuto)
                StartFactory();
        }

        /// <summary>
        /// Starts the factory producing spawned objects.
        /// </summary>
        public void StartFactory()
        {
            if (_cSpawning != null)
            {
                StopCoroutine(_cSpawning);
                _cSpawning = null;
            }
            _cSpawning = StartCoroutine(Spawning());
        }

        /// <summary>
        /// Stop the factory and clean up all objects associated with this factory and reset all properties.
        /// </summary>
        public void StopFactory()
        {
            if (_cSpawning != null)
            {
                StopCoroutine(_cSpawning);
                _cSpawning = null;
            }
            Reset();
        }

        /// <summary>
        /// Coroutine that handles timed spawning. Routine stops when factory is depleted of spawns.
        /// </summary>
        /// <returns></returns>
        private IEnumerator Spawning()
        {
            for (;;)
            {
                if (isPaused)
                    yield return 0;

                yield return new WaitForSeconds(UnityEngine.Random.Range(minTimeToWait, maxTimeToWait));

                if (ActiveSpawn < maxActiveSpawn || maxActiveSpawn <= 0)
                {
                    if (currentSpawn < totalSpawn || totalSpawn <= 0)
                    {
                        if (Spawn())
                        {
                            if (totalSpawn > 0)
                            {
                                currentSpawn++;

                                if (isRepeating)
                                {
                                    currentSpawn = currentSpawn % totalSpawn;
                                }
                            }
                        }
                    }
                    else
                    {
                        _isDepleted = true;
                    }
                }

                if (_isDepleted)
                    break;
            }
        }

        /// <summary>
        /// Spawn one object from the pool.
        /// </summary>
        /// <returns>Spawn success.</returns>
        public virtual bool Spawn()
        {
            if (pool.objects.Count > 0)
            {
                var obj = pool.GetObject();
                if (obj != null)
                {
                    activeObjects.Add(obj);

                    if (OnInitialize != null)
                    {
                        OnInitialize(obj);
                    }

                    InitializeObject(obj);

                    if (OnSpawn != null)
                    {
                        OnSpawn(obj);
                    }

                    return true;
                }
            }
            return false;
        }

        /// <summary>
        /// Reset all properties for the factory, clear active objects.
        /// </summary>
        public virtual void Reset()
        {
            activeObjects.Clear();
            currentSpawn = 0;
            _isDepleted = false;
        }

        /// <summary>
        /// Activate the game object.
        /// </summary>
        /// <param name="obj">Game object to activate.</param>
        public virtual void InitializeObject(GameObject obj)
        {
            float x = UnityEngine.Random.Range(xOffset.x, xOffset.y);
            float y = UnityEngine.Random.Range(yOffset.x, yOffset.y);
            float z = UnityEngine.Random.Range(zOffset.x, zOffset.y);

            Vector3 pos = Vector3.zero;

            if (spawnPositions.Count > 0)
            {
                pos = spawnPositions[UnityEngine.Random.Range(0, spawnPositions.Count)].position;
            }
            else
            {
                //Use own position if no other positions have been set.
                pos = this.transform.position;
            }

            obj.transform.position = new Vector3(pos.x + x, pos.y + y, pos.z + z);

            obj.SetActive(true);
        }

        public override void LateUpdate()
        {
            base.LateUpdate();

            //Check for any active objects that have been flagged for recycling by the pool in the latest update,
            //and remove them from the list of active objects.
            for (int i = 0; i < activeObjects.Count; i++)
            {
                var pooled = activeObjects[i].GetComponent<PooledObject>();
                if (pooled != null)
                {
                    if (pooled.bReuse && !pooled.gameObject.activeSelf)
                    {
                        activeObjects.RemoveAt(i);
                    }
                }
            }
        }
    }
}
