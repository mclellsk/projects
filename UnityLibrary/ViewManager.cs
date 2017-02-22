using UnityEngine;
using System.Collections.Generic;

namespace CapturedFlag.Engine
{
    /// <summary>
    /// Controls the screens to display. Only one manager should be active per scene.
    /// </summary>
    public class ViewManager : MonoBehaviour
    {
        /// <summary>
        /// Instance of view manager.
        /// </summary>
        public static ViewManager instance;

        /// <summary>
        /// View order draws the last in the list closest to the camera.
        /// </summary>
        private static List<View> viewOrder = new List<View>();

        /// <summary>
        /// All available screens in the scene.
        /// </summary>
        public static Dictionary<string, View> views = new Dictionary<string, View>();

        private void Awake()
        {
            instance = this;
            viewOrder.Clear();

            //Get all screens
            views.Clear();
            var v = (View[])Resources.FindObjectsOfTypeAll(typeof(View));
            for (int i = 0; i < v.Length; i++)
            {
                views.Add(v[i].ViewID, v[i]);
            }
        }

        /// <summary>
        /// Gets the view closest to the camera.
        /// </summary>
        /// <returns>ID of view.</returns>
        public static string GetActiveView()
        {
            if (viewOrder.Count > 0)
            {
                return viewOrder[viewOrder.Count - 1].ViewID;
            }
            return "";
        }

        /// <summary>
        /// Checks if the specified view is active.
        /// </summary>
        /// <param name="viewid">View to check.</param>
        /// <returns>True if view is active.</returns>
        public static bool IsViewActive(string viewid)
        {
            return viewOrder.FindIndex(p => p.ViewID == viewid) >= 0;
        }

        /// <summary>
        /// Checks if all of the specified views are currently active.
        /// </summary>
        /// <param name="viewids">Views to check.</param>
        /// <returns>True if all views are active.</returns>
        public static bool AreViewsActive(string[] viewids)
        {
            var result = true;
            for (int i = 0; i < viewids.Length; i++)
            {
                result = result & IsViewActive(viewids[i]);
            }
            return result;
        }

        /// <summary>
        /// Checks if any of the specified views are currently active.
        /// </summary>
        /// <param name="viewids">Views to check.</param>
        /// <returns>True if any of the views are active.</returns>
        public static bool AreAnyViewsActive(string[] viewids)
        {
            for (int i = 0; i < viewids.Length; i++)
            {
                if (IsViewActive(viewids[i]))
                    return true;
            }
            return false;
        }

        /// <summary>
        /// Moves screen to the front.
        /// </summary>
        /// <param name="viewid">View to move drawing priority.</param>
        public static void Show(string viewid)
        {
            Show(views[viewid]);
        }

        /// <summary>
        /// Moves a view to the front.
        /// </summary>
        /// <param name="view">ViewScreen object to move.</param>
        private static void Show(View view)
        {
            if (view != null)
            {
                viewOrder.Remove(view);
                viewOrder.Add(view);

                //Call Show Method on Screen, only called first time screen is activated
                if (!view.gameObject.activeSelf)
                {
                    view.gameObject.SetActive(true);
                }
                else
                    view.Focus();
            }
            else
                Debug.LogError("View does not exist.");
        }

        /// <summary>
        /// Hides a screen.
        /// </summary>
        /// <param name="viewid">View to hide.</param>
        /// <param name="force"></param>
        public static void Hide(string viewid)
        {
            Hide(views[viewid]);
        }

        /// <summary>
        /// Hides a screen.
        /// </summary>
        /// <param name="view">View to hide.</param>
        private static void Hide(View view)
        {
            if (view != null)
            {
                if (view.gameObject.activeSelf)
                {
                    var v = viewOrder.Find(p => p == view);
                    if (v != null)
                    {
                        view.StartHide();
                        viewOrder.Remove(v);
                    }
                }
            }
        }

        /// <summary>
        /// Hides all screens.
        /// </summary>
        public static void HideAll()
        {
            foreach (View v in viewOrder)
            {
                Hide(v);
            }
        }
    }
}