using UnityEngine;
using System.Collections.Generic;

namespace CapturedFlag.Engine
{
    /// <summary>
    /// This is used to manage the game state controllers. Only one state controller can be active at a time.
    /// </summary>
    public class StateManager : MonoBehaviour
    {
        /// <summary>
        /// Active instance of GameStateManager.
        /// </summary>
        public static StateManager instance;

        /// <summary>
        /// Determines if the manager has been flagged to change states.
        /// </summary>
        private static bool _bChange = false;

        /// <summary>
        /// The initial state of the manager.
        /// </summary>
        public State initialState;

        /// <summary>
        /// Current state of the manager.
        /// </summary>
        public State currentState;

        /// <summary>
        /// The state in the queue to be pushed to the new current state.
        /// </summary>
        private static State _nextState;

        /// <summary>
        /// Game states available.
        /// </summary>
        public static Dictionary<string, State> states = new Dictionary<string, State>();

        public void Awake()
        {
            instance = this;
        }

        public void Start()
        {
            states.Clear();
            var s = FindObjectsOfType<State>();
            for (int i = 0; i < s.Length; i++)
            {
                states.Add(s[i].StateID, s[i]);
            }

            if (initialState != null)
            {
                ChangeState(initialState.StateID);
            }
        }

        /// <summary>
        /// Change the current state to the new state. Ignores the call if the new state and the old state are the same.
        /// </summary>
        /// <param name="stateid">State to change to.</param>
        public static void ChangeState(string stateid)
        {
            var state = states[stateid];
            if (state != null)
            {
#if UNITY_EDITOR
                Debug.Log("Game State Changed: " + state.ToString());
#endif

                if (state != instance.currentState)
                {
                    _nextState = state;
                    if (instance.currentState != null)
                    {
                        instance.currentState.Exit();
                    }

                    _bChange = true;
                }
            }
        }

        public void Update()
        {
            //Load next state if one exists, and the change flag is true
            if (_bChange)
            {
                if (currentState != null)
                {
                    if (currentState.GetSubState == State.SubState.IDLE)
                    {
                        if (_nextState != null)
                        {
                            currentState = _nextState;
                            currentState.Enter();
                            _nextState = null;
                            _bChange = false;
                        }
                    }
                }
                else if (_nextState != null)
                {
                    currentState = _nextState;
                    currentState.Enter();
                    _nextState = null;
                    _bChange = false;
                }
            }
        }
    }
}
