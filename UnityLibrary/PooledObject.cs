using UnityEngine;
using System.Collections;

namespace CapturedFlag.Engine
{
    /// <summary>
    /// Attached to all objects that are created through an object pool.
    /// </summary>
    public class PooledObject : Actor
    {
        /// <summary>
        /// Index this object uses to reference itself in the pool of objects.
        /// </summary>
        public int index;
        /// <summary>
        /// Pool that this object belongs to.
        /// </summary>
        public Pool pool;
        /// <summary>
        /// Determines if this object is ready to be reused by the object pool.
        /// </summary>
        public bool bReuse = true;
        /// <summary>
        /// Original scale of the object.
        /// </summary>
        public Vector3 originalScale = Vector3.one;

        public override void Awake()
        {
            base.Awake();
            originalScale = this.transform.lossyScale;
        }

        /// <summary>
        /// Time to wait before recycling the object.
        /// </summary>
        /// <param name="timeToWait">Time to wait in seconds.</param>
        public void TimedRecycle(float timeToWait)
        {
            StartCoroutine(RecycleRoutine(timeToWait));
        }

        /// <summary>
        /// Coroutine to recycle object after waiting.
        /// </summary>
        /// <param name="timeToWait">Time to wait in seconds.</param>
        /// <returns></returns>
        private IEnumerator RecycleRoutine(float timeToWait)
        {
            yield return new WaitForSeconds(timeToWait);
            this.gameObject.Recycle();
        }
    }
}

