using UnityEngine;

namespace CapturedFlag.Engine
{
    public class EventCallbacks
    {
        public delegate void GameObjectHandler(GameObject gameObject);
        public delegate void ColliderHandler(Collider collider);
    }
}

