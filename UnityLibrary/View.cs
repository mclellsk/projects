using UnityEngine;
using System.Collections;

namespace CapturedFlag.Engine
{
    /// <summary>
    /// Handles screen show and hide behaviours and interacts with the ViewManager to ensure the correct draw order.
    /// Contains all front end logic.
    /// </summary>
    /// <remarks>
    /// Component should be added to the root GameObject which parents all other UI components.
    /// </remarks>
    public class View : Actor
    {
        /// <summary>
        /// Screen will hide callback.
        /// </summary>
        public event System.Action OnHide;
        /// <summary>
        /// Screen will be focused on callback.
        /// </summary>
        public event System.Action OnFocus;

        /// <summary>
        /// Determines if the screen is in the middle of an enter or exit screen transition.
        /// </summary>
        private bool _inTransition = false;

        /// <summary>
        /// Screen transition coroutine.
        /// </summary>
        private Coroutine _cTransition;

        /// <summary>
        /// Determines if the screen is in the middle of an enter or exit screen transition.
        /// </summary>
        public bool InTransition
        {
            get { return _inTransition; }
        }
        /// <summary>
        /// Name of the view, used to reference screens in the ViewManager.
        /// </summary>
        public virtual string ViewID
        {
            get
            {
                return "";
            }
        }

        public override void Awake()
        {
            base.Awake();

            var vc = transform.parent.gameObject.GetComponent<ViewController>();
            if (vc != null)
            {
                vc.view = this;
            }
        }

        public override void Update()
        {
            base.Update();

            if (!_inTransition)
            {
                UpdateView();
            }
        }

        /// <summary>
        /// Only called when the screen is not in the process of transitioning.
        /// </summary>
        public virtual void UpdateView() { }

        /// <summary>
        /// Starts the show screen coroutine.
        /// </summary>
        private void StartShow()
        {
            StopTransition();

            _inTransition = true;
            _cTransition = StartCoroutine(Show());
        }

        /// <summary>
        /// Starts the hide screen coroutine.
        /// </summary>
        public void StartHide()
        {
            if (OnHide != null)
            {
                OnHide();
            }

            StopTransition();

            _inTransition = true;
            _cTransition = StartCoroutine(Hide());
        }

        /// <summary>
        /// Stops any transition coroutine.
        /// </summary>
        private void StopTransition()
        {
            if (_cTransition != null)
            {
                StopCoroutine(_cTransition);
                _cTransition = null;
            }

            _inTransition = false;
        }

        /// <summary>
        /// This method is only called the first time the screen goes from a hidden to a visible state.
        /// </summary>
        public override void Initialize()
        {
            base.Initialize();
            StartShow();
            Focus();
        }

        /// <summary>
        /// Screen is focused and shown again when coming from an inactive to active state.
        /// </summary>
        public override void OnReEnable()
        {
            base.OnReEnable();
            StartShow();
            Focus();
        }

        /// <summary>
        /// Called whenever the screen is brought to the front of the view order.
        /// </summary>
        public virtual void Focus()
        {
            StopTransition();

            if (OnFocus != null)
            {
                OnFocus();
            }
        }

        /// <summary>
        /// This coroutine is called when the screen goes from a hidden to a visible state. Enter transitions and animations belong here.
        /// </summary>
        /// <returns></returns>
        public virtual IEnumerator Show()
        {
            //Animations go here...

            //These must go last in the coroutine
            _inTransition = false;
            yield return 0;
        }

        /// <summary>
        /// This coroutine is called when the screen goes from a visible to a hidden state. Exit transitions and animations belong here.
        /// </summary>
        /// <returns></returns>
        public virtual IEnumerator Hide()
        {
            //Animations go here...

            //These must go last in the coroutine
            yield return 0;
            _inTransition = false;
            gameObject.SetActive(false);
        }
    }
}
