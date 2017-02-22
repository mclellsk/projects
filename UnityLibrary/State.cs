using UnityEngine;
using System.Collections;

namespace CapturedFlag.Engine
{
    /// <summary>
    /// The GameStateController is generally the logic controller for the current scene, every scene can have multiple game states.
    /// Properties related to the game should not be stored here but in a model class so that states outside of this state can reference them.
    /// </summary>
    public abstract class State : MonoBehaviour
    {
        /// <summary>
        /// Name of state used for reference in state manager.
        /// </summary>
        public virtual string StateID
        {
            get { return ""; }
        }

        /// <summary>
        /// Specific sub states within the state.
        /// </summary>
        public enum SubState
        {
            IDLE,
            ENTER,
            UPDATE,
            UNLOAD,
            EXIT
        };
        /// <summary>
        /// Current sub state.
        /// </summary>
        private SubState _state = SubState.IDLE;

        /// <summary>
        /// Enter state callback.
        /// </summary>
        public event System.Action OnStateEnter;
        /// <summary>
        /// Exit state callback.
        /// </summary>
        public event System.Action OnStateExit;
        /// <summary>
        /// Clean-up state callback.
        /// </summary>
        public event System.Action OnStateUnload;

        /// <summary>
        /// Get current sub state.
        /// </summary>
        public SubState GetSubState
        {
            get
            {
                return _state;
            }
        }
        /// <summary>
        /// Whenever a substate is changed, the state callbacks are called here.
        /// </summary>
        private SubState SetSubState
        {
            set
            {
                _state = value;

                switch (_state)
                {
                    case SubState.ENTER:
                        if (OnStateEnter != null)
                            OnStateEnter();
                        break;
                    case SubState.EXIT:
                        if (OnStateExit != null)
                            OnStateExit();
                        break;
                    case SubState.UNLOAD:
                        if (OnStateUnload != null)
                            OnStateUnload();
                        break;
                    default:
                        break;
                }
            }
        }

        /// <summary>
        /// Called when this state becomes the primary game state.
        /// </summary>
        public void Enter()
        {
            SetSubState = SubState.ENTER;
            EnterState();
            SetSubState = SubState.UPDATE;
        }

        /// <summary>
        /// Called when this state is no longer the primary game state.
        /// </summary>
        public void Exit()
        {
            SetSubState = SubState.UNLOAD;
            //Wait for unload to complete before moving to exit state
            StartCoroutine(WaitForUnload());
        }

        private void Update()
        {
            if (GetSubState == SubState.UPDATE)
            {
                UpdateState();
            }
        }

        /// <summary>
        /// Logic for when the state is entered.
        /// </summary>
        public virtual void EnterState() { }

        /// <summary>
        /// Logic for the duration this state is active.
        /// </summary>
        public virtual void UpdateState() { }

        /// <summary>
        /// Logic for the unloading of state related entities, or even waiting for the unloading of entities.
        /// </summary>
        public virtual void UnloadState()
        {
            //Move to next state...
            //The substate condition check must be done at the end of this method.
            SetSubState = SubState.EXIT;
        }

        /// <summary>
        /// Logic for when the state is left.
        /// </summary>
        public virtual void ExitState() { }

        /// <summary>
        /// Coroutine to wait for the state to completely unload.
        /// </summary>
        /// <returns></returns>
        private IEnumerator WaitForUnload()
        {
            for (;;)
            {
                if (GetSubState == SubState.EXIT)
                {
                    //Move to exit state
                    ExitState();
                    SetSubState = SubState.IDLE;
                    yield break;
                }
                else
                {
                    UnloadState();
                    yield return 0;
                }
            }
        }
    }
}
