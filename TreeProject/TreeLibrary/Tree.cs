using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TreeLibrary
{
    public class AVLNode
    {
        public int value;
        public int count;

        public AVLNode parent;
        public AVLNode left;
        public AVLNode right;

        public int balance;

        public AVLNode(int value)
        {
            parent = left = right;
            this.value = value;
            this.count = 1;
        }

        public AVLNode Copy()
        {
            var node = new AVLNode(value);
            node.left = left;
            node.right = right;
            node.parent = parent;
            node.count = count;
            return node;
        }
    }

    public class AVLTree
    {
        /// <summary>
        /// Root node of the AVL tree
        /// </summary>
        public AVLNode root;

        /// <summary>
        /// Search for node with the same value using binary search.
        /// </summary>
        /// <param name="value">Value to search for.</param>
        /// <returns>Returns node if found, else a null value.</returns>
        public AVLNode Search(int value, AVLNode n)
        {
            if (n == null)
                return null;

            if (value < n.value)
            {
                return Search(value, n.left);
            }
            else if (value > n.value)
            {
                return Search(value, n.right);
            }
            else
                return n;
        }
        
        /// <summary>
        /// Inserts a node with the given value in the tree using binary search. Requires rebalancing to be applied
        /// once node has been added. If the value already exists, simply increment the count of the node.
        /// </summary>
        /// <param name="value"></param>
        public void Insert(int value, ref AVLNode parent)
        {
            if (parent == null)
            {
                parent = new AVLNode(value);
                return;
            }

            if (value < parent.value)
            {
                //Search left node
                if (parent.left != null)
                    Insert(value, ref parent.left);
                else
                {
                    var node = new AVLNode(value);
                    node.parent = parent;
                    parent.left = node;
                    BalanceNode(parent.left);
                }
            }
            else if (value > parent.value)
            {
                //Search right node
                if (parent.right != null)
                    Insert(value, ref parent.right);
                else
                {
                    var node = new AVLNode(value);
                    node.parent = parent;
                    parent.right = node;
                    BalanceNode(parent.right);
                }
            }
            else
            {
                parent.count++;
            }
        }

        /// <summary>
        /// Removes a count on the node with the value provided if found starting at node n. 
        /// Removes the actual node if the count falls to 0.
        /// </summary>
        /// <param name="value">Value of the node to remove.</param>
        /// <param name="n">Root node to start search at.</param>
        public void Delete(int value, ref AVLNode n)
        {
            if (n == null)
                return;

            if (n.value == value)
            {
                //Node found, remove
                n.count--;
                if (n.count <= 0)
                {
                    DeleteHelper(ref n);
                    BalanceNode(n);
                }
            }
            else if (value < n.value)
            {
                //Search left node
                Delete(value, ref n.left);
            }
            else if (value > n.value)
            {
                //Search right node
                Delete(value, ref n.right);
            }
        }

        /// <summary>
        /// Helper function to remove node. If a node has multiple children, recursion occurs to 
        /// shift the children on the left up one hierarchial level.
        /// </summary>
        /// <param name="n">Node to remove.</param>
        private void DeleteHelper(ref AVLNode n)
        {
            if (n.left == null && n.right == null)
            {
                //Node has no children
                n = null;
            }
            else if (n.left == null && n.right != null)
            {
                //Node has one child on the right
                var parent = n.parent;
                n = n.right;
                n.parent = parent;
            }
            else if (n.left != null && n.right == null)
            {
                //Node has one child on the left
                var parent = n.parent;
                n = n.left;
                n.parent = parent;
            }
            else
            {
                //Replace the node with the node preceding it (left child)
                var parent = n.parent;
                var right = n.right;
                n = n.left;
                n.parent = parent;
                n.right = right;
                //Recursively replace all left nodes with their preceding nodes until one of the above conditions are met
                DeleteHelper(ref n.left);
            }
        }

        /// <summary>
        /// If the height of the node is negative, there is no node, otherwise, the height of the node is returned.
        /// </summary>
        /// <param name="n">Node to get the height of.</param>
        /// <returns>Height of the node.</returns>
        private int GetHeight(AVLNode n)
        {
            if (n == null)
                return 0;

            int left = 1;
            int right = 1;

            if (n.left != null)
            {
                Console.WriteLine("child:" + n.left.value);
                left += GetHeight(n.left);
            }
            if (n.right != null)
                right += GetHeight(n.right);

            //Console.WriteLine("height node:{0} heightLeft:{1} heightRight:{2}", n.value, left, right);

            return Math.Max(left, right);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="n"></param>
        public void BalanceNode(AVLNode n)
        {
            while (n != null)
            {
                Console.WriteLine("nodeToBalance:{0}", n.value.ToString());

                var left = GetHeight(n.left);
                var right = GetHeight(n.right);

                var nodeBalance = right - left;
                Console.WriteLine("balance:{0}", nodeBalance);
                if (nodeBalance < -1) //Left heavy
                {
                    //Balance of the left child
                    var leftBalance = GetHeight(n.left.right) - GetHeight(n.left.left);
                    if (leftBalance < 0) //Left node left heavy
                        n = RightRotate(n);
                    else if (leftBalance > 0) //Left node right heavy
                        n = LeftRightRotate(n);
                }
                else if (nodeBalance > 1) //Right heavy
                {
                    //Balance of the right child
                    var rightBalance = GetHeight(n.right.right) - GetHeight(n.right.left);
                    if (rightBalance > 0) //Right node right heavy
                        n = LeftRotate(n);
                    else if (rightBalance < 0) //Right node left heavy
                        n = RightLeftRotate(n);
                }

                if (n.parent == null)
                    root = n;

                Console.WriteLine("node:{0} left:{1} right:{2} parent:{3}", n.value, (n.left != null) ? n.left.value.ToString() : "none", (n.right != null) ? n.right.value.ToString() : "none", (n.parent != null) ? n.parent.value.ToString() : "none");

                n = n.parent;
            }
            Console.WriteLine("done balance");
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="r"></param>
        /// <param name="parent"></param>
        public AVLNode LeftRotate(AVLNode r)
        {
            //Create a copy root
            var pivot = r;
            //Set the new root to be a copy of the left node
            r = pivot.right;

            //Set the value of the right child of the pivot to the left child of the new root
            if (r.left != null)
                pivot.right = r.left;
            else
                pivot.right = null;

            //Set the parent of the right child to the pivot
            if (pivot.right != null)
                pivot.right.parent = pivot;
            //Set the left child of the new root to the pivot
            r.left = pivot;
            //Set the parent's child to the new root
            if (pivot.parent != null)
                pivot.parent.right = r;
            //Set the parent of the root to the parent of the pivot
            r.parent = pivot.parent;
            //Set the parent of the pivot to the root
            pivot.parent = r;
            return r;
        }

        /// <summary>
        /// Rotate the node to the right.
        /// </summary>
        /// <param name="r">Node to rotate.</param>
        public AVLNode RightRotate(AVLNode r)
        {
            //Create a copy root
            var pivot = r;
            //Set the new root to be a copy of the left node
            r = pivot.left;

            //Set the value of the left child of the pivot to the right child of the new root
            if (r.right != null)
                pivot.left = r.right;
            else
                pivot.left = null;

            //Set the parent of the left child to the pivot
            if (pivot.left != null)
                pivot.left.parent = pivot;
            //Set the right child of the new root to the pivot
            r.right = pivot;
            //Set the parent's child to the new root
            if (pivot.parent != null)
                pivot.parent.left = r;
            //Set the parent of the root to the parent of the pivot
            r.parent = pivot.parent;
            //Set the parent of the pivot to the root
            pivot.parent = r;
            return r;
        }

        /// <summary>
        /// Rotate the left child node to the left, then rotate the current node to the right.
        /// </summary>
        /// <param name="r"></param>
        private AVLNode LeftRightRotate(AVLNode r)
        {
            r.left = LeftRotate(r.left);
            r = RightRotate(r);
            return r;
        }

        /// <summary>
        /// Rotate the right child node to the right, then rotate the current node to the left.
        /// </summary>
        /// <param name="r"></param>
        /// <param name="parent"></param>
        private AVLNode RightLeftRotate(AVLNode r)
        {
            r.right = RightRotate(r.right);
            r = LeftRotate(r);
            return r;
        }
    }
}
