using UnityEngine;

namespace CapturedFlag.Engine
{
    /// <summary>
    /// Base class for all behaviours. Methods are listed in order of when they are called in the lifecycle.
    /// </summary>
    public class Actor : MonoBehaviour
    {
        /// <summary>
        /// Determines if the behaviour has already initialized.
        /// </summary>
        public bool IsInitialized { get; set; }

        /// <summary>
        /// Called when object is created, whether the component is activated or not as long as the gameObject it is attached to is active.
        /// </summary>
        public virtual void Awake() { }

        /// <summary>
        /// Called when the object goes from a disabled to enabled state. Includes the first time it is ever activated.
        /// </summary>
        public virtual void OnEnable()
        {
            if (IsInitialized)
            {
                OnReEnable();
            }
        }

        /// <summary>
        /// Called when the object goes from a disabled to enabled state after the initialization has already occurred.
        /// </summary>
        public virtual void OnReEnable() { }

        /// <summary>
        /// Called when the object starts for the first time. Should contain any configurations that put it into a base state, can be reused to reinitialize at another point.
        /// </summary>
        public virtual void Initialize() { }

        /// <summary>
        /// Called when the object is activated for the first time.
        /// </summary>
        public virtual void Start()
        {
            Initialize();
            IsInitialized = true;
        }

        /// <summary>
        /// Called every frame update.
        /// </summary>
        public virtual void Update() { }

        /// <summary>
        /// Called every physics update.
        /// </summary>
        public virtual void FixedUpdate() { }

        /// <summary>
        /// Called last in frame update.
        /// </summary>
        public virtual void LateUpdate() { }

        /// <summary>
        /// Called when the object goes from an enabled to disabled state.
        /// </summary>
        public virtual void OnDisable() { }

        /// <summary>
        /// Called when the object is destroyed.
        /// </summary>
        public virtual void OnDestroy() { }

        /// <summary>
        /// Called when this object's collider/rigidbody begins touching another collider/rigidbody.
        /// </summary>
        public virtual void OnCollisionEnter(Collision collision) { }

        /// <summary>
        /// Called when this object's collider/rigidbody is still touching another collider/rigidbody.
        /// </summary>
        /// <param name="collision"></param>
        public virtual void OnCollisionStay(Collision collision) { }

        /// <summary>
        /// Called when this object's collider/rigidbody stops touching another collider/rigidbody.
        /// </summary>
        /// <param name="collision"></param>
        public virtual void OnCollisionExit(Collision collision) { }

        /// <summary>
        /// Called when a collider/rigidbody begins touching a trigger.
        /// </summary>
        /// <param name="collider"></param>
        public virtual void OnTriggerEnter(Collider collider) { }

        /// <summary>
        /// Called when a collider/rigidbody is still touching a trigger.
        /// </summary>
        /// <param name="collider"></param>
        public virtual void OnTriggerStay(Collider collider) { }

        /// <summary>
        /// Called when a collider/rigidbody stops touching a trigger.
        /// </summary>
        /// <param name="collider"></param>
        public virtual void OnTriggerExit(Collider collider) { }

        /// <summary>
        /// Instantiates a GameObject with the given position and rotation, optional parent and name.
        /// </summary>
        /// <param name="gameObject">Game object to instantiate.</param>
        /// <param name="position">Position to place game object.</param>
        /// <param name="rotation">Rotation of game object.</param>
        /// <param name="parent">Parent of game object.</param>
        /// <param name="name">Name of game object.</param>
        /// <returns></returns>
        public static GameObject Instantiate(UnityEngine.Object gameObject, Vector3 position, Quaternion rotation, Transform parent = null, string name = "Default")
        {
            var obj = (GameObject)(UnityEngine.GameObject.Instantiate(gameObject, position, rotation));
            obj.transform.parent = parent;
            obj.name = name;
            return obj;
        }
    }
}