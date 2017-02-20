using System;

namespace TreeLibrary
{
    public class AVLNode
    {
        public int value;
        public int count;

        public AVLNode parent;
        public AVLNode left;
        public AVLNode right;

        public AVLNode(int value)
        {
            parent = left = right;
            this.value = value;
            count = 1;
        }

        /// <summary>
        /// Perform a shallow copy of the node.
        /// </summary>
        /// <returns>Copy of node.</returns>
        public AVLNode Clone()
        {
            return (AVLNode)this.MemberwiseClone();
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
        /// <param name="value">Value to add to the tree.</param>
        /// <param name="n">Node to start search for insertion point at.</param>
        public void Insert(int value, ref AVLNode n)
        {
            if (n == null)
            {
                n = new AVLNode(value);
                return;
            }

            if (value < n.value)
            {
                //Search left node
                if (n.left != null)
                    Insert(value, ref n.left);
                else
                {
                    var node = new AVLNode(value);
                    node.parent = n;
                    n.left = node;
                    BalanceNode(n.left);
                }
            }
            else if (value > n.value)
            {
                //Search right node
                if (n.right != null)
                    Insert(value, ref n.right);
                else
                {
                    var node = new AVLNode(value);
                    node.parent = n;
                    n.right = node;
                    BalanceNode(n.right);
                }
            }
            else
            {
                n.count++;
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
            if (n == null)
                return;
            
            if (n.left == null && n.right == null)
            {
                //Node has no children
                n = null;
            }
            else if (n.left == null && n.right != null)
            {
                //Node has one child on the right
                var pivot = n.Clone();
                n = pivot.right;
                n.parent = pivot.parent;
                if (pivot.parent != null)
                {
                    if (pivot.parent.left != null)
                    {
                        if (pivot.parent.left.value == pivot.value)
                            n.parent.left = n;
                    }
                    if (pivot.parent.right != null)
                    {
                        if (pivot.parent.right.value == pivot.value)
                            n.parent.right = n;
                    }
                }
            }
            else if (n.left != null && n.right == null)
            {
                //Node has one child on the left
                var pivot = n.Clone();
                n = pivot.left;
                n.parent = pivot.parent;
                if (pivot.parent != null)
                {
                    if (pivot.parent.left != null)
                    {
                        if (pivot.parent.left.value == pivot.value)
                            n.parent.left = n;
                    }
                    if (pivot.parent.right != null)
                    {
                        if (pivot.parent.right.value == pivot.value)
                            n.parent.right = n;
                    }
                }
            }
            else
            {
                //Replace the node with the node preceding it (left child)
                var pivot = n.Clone();
                n = pivot.left;
                n.parent = pivot.parent;
                if (pivot.parent != null)
                {
                    if (pivot.parent.left != null)
                    {
                        if (pivot.parent.left.value == pivot.value)
                            n.parent.left = n;
                    }
                    else if (pivot.parent.right != null)
                    {
                        if (pivot.parent.right.value == pivot.value)
                            n.parent.right = n;
                    }
                }
                n.right = pivot.right;
                n.right.parent = n;
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
                left += GetHeight(n.left);
            }
            if (n.right != null)
                right += GetHeight(n.right);

            return Math.Max(left, right);
        }

        /// <summary>
        /// Checks the current node for an unacceptable difference in height between the left and right child nodes.
        /// If this is greater than or equal to 2, the node is rotated to ensure the property is maintained. This function
        /// is then applied recursively to the parent until no parent exists (meaning you have reached the root node).
        /// </summary>
        /// <param name="n">Node to balance</param>
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
        /// Rotate the node to the left.
        /// </summary>
        /// <param name="r">Node to rotate.</param>
        /// <returns>New root after rotation.</returns>
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
            {
                if (pivot.parent.left != null)
                {
                    if (pivot.parent.left.value == pivot.value)
                        pivot.parent.left = r;
                }
                if (pivot.parent.right != null)
                {
                    if (pivot.parent.right.value == pivot.value)
                        pivot.parent.right = r;
                }
            }
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
        /// <returns>New root after rotation.</returns>
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
            {
                if (pivot.parent.left != null)
                {
                    if (pivot.parent.left.value == pivot.value)
                        pivot.parent.left = r;
                }
                if (pivot.parent.right != null)
                {
                    if (pivot.parent.right.value == pivot.value)
                        pivot.parent.right = r;
                }
            }
            //Set the parent of the root to the parent of the pivot
            r.parent = pivot.parent;
            //Set the parent of the pivot to the root
            pivot.parent = r;
            return r;
        }

        /// <summary>
        /// Rotate the left child node to the left, then rotate the current node to the right.
        /// </summary>
        /// <param name="r">Node to apply double rotation.</param>
        /// <returns>New root after rotation.</returns>
        private AVLNode LeftRightRotate(AVLNode r)
        {
            r.left = LeftRotate(r.left);
            r = RightRotate(r);
            return r;
        }

        /// <summary>
        /// Rotate the right child node to the right, then rotate the current node to the left.
        /// </summary>
        /// <param name="r">Node to apply double rotation.</param>
        /// <returns>New root after rotation.</returns>
        private AVLNode RightLeftRotate(AVLNode r)
        {
            r.right = RightRotate(r.right);
            r = LeftRotate(r);
            return r;
        }
    }
}
