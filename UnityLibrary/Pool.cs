using UnityEngine;
using System.Collections.Generic;

namespace CapturedFlag.Engine
{
    /// <summary>
    /// Extender class for pooling related methods.
    /// </summary>
    public static class PoolExtender
    {
        /// <summary>
        /// Attempt to recycle a game object returning it back to the pool it is associated with.
        /// </summary>
        /// <param name="obj">Object to recycle.</param>
        /// <returns>Success of recycle.</returns>
        public static bool Recycle(this GameObject obj)
        {
            if (obj != null)
            {
                var poolObj = obj.GetComponent<PooledObject>();

                if (poolObj != null)
                {
                    //Set Parent to Root of Scene
                    poolObj.transform.SetParent(null);
                    //Reset Scale
                    poolObj.transform.localScale = poolObj.originalScale;
                    //Reset Parent
                    if (poolObj.pool != null)
                        poolObj.transform.SetParent(poolObj.pool.transform, false);
                    poolObj.transform.localPosition = Vector3.zero;
                    obj.SetActive(false);
                    poolObj.bReuse = true;
                    return true;
                }
                else
                {
                    return false;
                }
            }
            else
                return false;
        }

        /// <summary>
        /// Attempt to recycle a game object returning it back to the pool it is associated with after a specified amount of time.
        /// </summary>
        /// <param name="obj">Object to be recycled.</param>
        /// <param name="timeToWait">Time to wait before attempting to recycle.</param>
        public static void TimedRecycle(this GameObject obj, float timeToWait)
        {
            var pooledObj = obj.GetComponent<PooledObject>();
            if (pooledObj != null)
            {
                pooledObj.TimedRecycle(timeToWait);
            }
        }
    }

    /// <summary>
    /// Acts as a pool of gameobjects. Prevents use of instantiate during runtime.
    /// As soon as the root gameobject is set to inactive, it is set for recycling.
    /// Used to reduce microstuttering.
    /// </summary>
    /// <remarks>
    /// This behaviour should execute ahead of default time in the Script Execution Order,
    /// to register the pools in the static dictionary to be used at runtime to prevent other scripts
    /// from being unable to reference the pool in the Awake state.
    /// </remarks>
    public class Pool : Actor
    {
        /// <summary>
        /// Dictionary of all instanced pools available. Key is the name of the gameobject the pool is attached to.
        /// </summary>
        public static Dictionary<string, Pool> pools = new Dictionary<string, Pool>();

        /// <summary>
        /// The object to clone in this pool.
        /// </summary>
        public GameObject prefab;

        /// <summary>
        /// The number of objects to instantiate for this pool based on the prefab.
        /// </summary>
        public int objectCount = 0;

        /// <summary>
        /// The objects created by this pool.
        /// </summary>
        public List<GameObject> objects = new List<GameObject>();

        /// <summary>
        /// This will determine if the pool can create additional objects if the limit of active objects has been reached.
        /// </summary>
        public bool isScalingAllowed = false;

        /// <summary>
        /// The factor to increase the pool size by when scaling.
        /// </summary>
        public float scalingFactor = 0.1f;

        public override void Awake()
        {
            base.Awake();

            pools.Add(gameObject.name, this);
        }

        public override void Initialize()
        {
            base.Initialize();

            for (int i = 0; i < objectCount; i++)
            {
                var obj = GameObject.Instantiate(prefab);
                obj.name = obj.name + "-" + i.ToString();
                obj.AddComponent(typeof(PooledObject));
                obj.SetActive(false);
                obj.GetComponent<PooledObject>().pool = this;
                obj.GetComponent<PooledObject>().index = i;
                obj.transform.SetParent(this.transform, false);
                objects.Add(obj);
            }
        }

        /// <summary>
        /// Create an instance of an object pool.
        /// </summary>
        /// <param name="name">Name of pool for referencing in the dictionary</param>
        /// <param name="prefab">Prefab to clone.</param>
        /// <param name="count">Number of instantiations.</param>
        /// <returns>Success of creation.</returns>
        public static Pool CreatePool(string name, GameObject prefab, int count)
        {
            GameObject obj = new GameObject(name);
            var pool = obj.AddComponent<Pool>();
            pool.prefab = prefab;
            pool.objectCount = count;
            pool.Initialize();
            return pool;
        }

        /// <summary>
        /// Get the instance of the object pool stored in the dictionary by the name of the pool.
        /// </summary>
        /// <param name="name">Name of the object pool.</param>
        /// <returns>Pool instance.</returns>
        public static Pool GetPool(string name)
        {
            if (pools.ContainsKey(name))
            {
                return pools[name];
            }
            else
                return null;
        }

        /// <summary>
        /// Returns the first instance of an object that is inactive and ready for use.
        /// </summary>
        /// <returns>The inactive object.</returns>
        public GameObject GetObject()
        {
            var obj = objects.Find(p => p.GetComponent<PooledObject>().bReuse == true);
            if (obj != null)
            {
                obj.GetComponent<PooledObject>().bReuse = false;
            }
            else if (isScalingAllowed)
            {
                //Scale up pool size by the scalingFactor if pool is depleted
                var scaleCount = Mathf.Max(1, (int)(scalingFactor * objectCount));
                var index = (objects.Count - 1);
                for (int i = 0; i < scaleCount; i++)
                {
                    var newIndex = index + i;
                    var newObj = GameObject.Instantiate(prefab);
                    newObj.name = newObj.name + "-" + newIndex.ToString();
                    newObj.AddComponent(typeof(PooledObject));
                    newObj.SetActive(false);
                    newObj.GetComponent<PooledObject>().pool = this;
                    newObj.GetComponent<PooledObject>().index = newIndex;
                    newObj.transform.SetParent(this.transform, false);
                    objects.Add(newObj);
                }
                return GetObject();
            }
            return obj;
        }

        public override void OnDestroy()
        {
            base.OnDestroy();

            pools.Remove(gameObject.name);
        }

        /// <summary>
        /// Recycle all objects associated with this pool.
        /// </summary>
        public void Reset()
        {
            foreach (GameObject obj in objects)
            {
                obj.Recycle();
            }
        }
    }
}