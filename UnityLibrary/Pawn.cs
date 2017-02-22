using UnityEngine;
using System.Collections;

namespace CapturedFlag.Engine
{
    [RequireComponent(typeof(Rigidbody))]
    public class Pawn : Actor
    {
        public enum PawnState
        {
            ALIVE,
            DYING,
            DEAD
        };

        public int maxHealth = 100;
        public int maxArmor = 50;

        protected Rigidbody _rigidBody;

        protected float _timeUntilDead = 10f;
        protected float _speed = 1f;

        private string _name;
        private string _description;

        private PawnState _state = PawnState.ALIVE;

        public bool IsFrozen { get; set; }
        public bool CanTakeDamage { get; set; }
        public bool CanDie { get; set; }
        public bool IsAlive
        {
            get
            {
                return _state == PawnState.ALIVE;
            }
        }

        public virtual float Speed
        {
            get { return _speed; }
        }

        public override void Awake()
        {
            base.Awake();

            _rigidBody = GetComponent<Rigidbody>();
        }

        public override void OnDisable()
        {
            base.OnDisable();

            //Remove all forces on rigidbody
            if (_rigidBody != null)
                _rigidBody.velocity = Vector3.zero;
        }

        public override void Start()
        {
            base.Start();
        }

        public override void Update()
        {
            base.Update();

            if (IsAlive)
            {
                //Do something while alive...
            }
        }

        public override void FixedUpdate()
        {
            base.FixedUpdate();

            if (IsFrozen)
            {
                //Do not allow movement
                _rigidBody.velocity = Vector3.zero;
            }
        }

        public virtual void Alive()
        {
            _state = PawnState.ALIVE;
        }

        public virtual void Dying()
        {
            _rigidBody.velocity = Vector3.zero;
            _state = PawnState.DYING;
            StartCoroutine(WaitForDeath(_timeUntilDead));
        }

        public virtual void Dead()
        {
            _state = PawnState.DEAD;
        }

        public IEnumerator WaitForDeath(float time)
        {
            yield return new WaitForSeconds(time);
            Dead();
        }
    }
}