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

        private void InsertNode()
        {
            tree.Insert(Convert.ToInt32(txtValue.Text), ref tree.root);
            UpdateTreeView();
            txtValue.ResetText();
        }

        private void UpdateTreeView()
        {
            treeView.Nodes.Clear();
            var nodes = SearchTree(tree.root);
            if (nodes != null)
                treeView.Nodes.Add(nodes);

            treeView.ExpandAll();
        }

        private TreeNode SearchTree(AVLNode n)
        {
            if (n == null)
                return null;

            var list = new List<TreeNode>();
            if (n.right != null)
                list.Add(SearchTree(n.right));
            if (n.left != null)
                list.Add(SearchTree(n.left));

            if (list.Count > 0)
                return new TreeNode(n.value.ToString(), list.ToArray());
            else
                return new TreeNode(n.value.ToString());
        }

        private void btnBalance_Click(object sender, EventArgs e)
        {
            //tree.BalanceNode(ref tree.root);
            //tree.LeftRotate(ref tree.root);
            UpdateTreeView();
        }

        private void btnDelete_Click(object sender, EventArgs e)
        {
            tree.Delete(Convert.ToInt32(txtValue.Text), ref tree.root);
            UpdateTreeView();
        }
    }
}
