using UnityEngine;

namespace CapturedFlag.Engine
{
    /// <summary>
    /// This is the parent class of a screen controller, contains the behaviour logic for the view.
    /// ScreenController -> SpecificScreenController (cast) -> ChildController1, ChildController2...
    /// This component needs to be the in the parent object of the ViewScreen which uses this controller.
    /// </summary>
    public abstract class ViewController : Actor
    {
        /// <summary>
        /// The screen which this controller handles the back-end logic for.
        /// </summary>
        [HideInInspector]
        public View view;
    }
}
