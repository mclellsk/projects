using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using TreeLibrary;

namespace TreeProject
{
    public partial class formMain : Form
    {
        public AVLTree tree;

        public formMain()
        {
            //Initialize tree
            tree = new AVLTree();
            InitializeComponent();
            txtValue.KeyDown += TxtValue_KeyDown;
        }

        private void TxtValue_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Enter)
                InsertNode();
        }

        private void btnInsert_Click(object sender, EventArgs e)
        {
            InsertNode();
        }

        private void btnDelete_Click(object sender, EventArgs e)
        {
            DeleteNode();
        }

        private void btnSearch_Click(object sender, EventArgs e)
        {
            SearchNode();
        }

        private void InsertNode()
        {
            if (!String.IsNullOrEmpty(txtValue.Text))
            {
                tree.Insert(Convert.ToInt32(txtValue.Text), ref tree.root);
                UpdateTreeView();
                txtValue.ResetText();
            }
        }

        private void DeleteNode()
        {
            if (!String.IsNullOrEmpty(txtValue.Text))
            {
                tree.Delete(Convert.ToInt32(txtValue.Text), ref tree.root);
                UpdateTreeView();
                txtValue.ResetText();
            }
        }

        private void SearchNode()
        {
            if (!String.IsNullOrEmpty(txtValue.Text))
            {
                var value = Convert.ToInt32(txtValue.Text);
                Search(value);
                txtValue.ResetText();
            }
        }

        private void UpdateTreeView()
        {
            treeView.Nodes.Clear();
            var nodes = MapTree(tree.root);
            if (nodes != null)
                treeView.Nodes.Add(nodes);

            treeView.ExpandAll();
        }

        private void Search(int value)
        {
            var result = SearchTree(value, treeView.TopNode);
            if (result != null)
                treeView.SelectedNode = result;
            treeView.Focus();
        }

        private TreeNode SearchTree(int value, TreeNode root)
        {
            if (root == null)
                return null;

            TreeNode left = null;
            TreeNode right = null;

            if (root.Nodes.Count == 2)
            {
                if (Convert.ToInt32(root.Nodes[0].Text) > Convert.ToInt32(root.Text))
                {
                    right = root.Nodes[0];
                    left = root.Nodes[1];
                }
                else
                {
                    right = root.Nodes[1];
                    left = root.Nodes[0];
                }                
            }
            else if (root.Nodes.Count == 1)
            {
                if (Convert.ToInt32(root.Nodes[0].Text) > Convert.ToInt32(root.Text))
                    right = root.Nodes[0];
                else
                    left = root.Nodes[0];
            }

            if (value > Convert.ToInt32(root.Text))
            {
                //Check Right Node
                return SearchTree(value, right);
            }
            else if (value < Convert.ToInt32(root.Text))
            {
                //Check Left Node
                return SearchTree(value, left);
            }
            else
            {
                return root;
            }
        }

        private TreeNode MapTree(AVLNode n)
        {
            if (n == null)
                return null;

            var list = new List<TreeNode>();
            if (n.right != null)
                list.Add(MapTree(n.right));
            if (n.left != null)
                list.Add(MapTree(n.left));

            if (list.Count > 0)
                return new TreeNode(n.value.ToString(), list.ToArray());
            else
                return new TreeNode(n.value.ToString());
        }
    }
}
