class BinaryTree {
  BinaryTree(this.value);
  BinaryTree.withLeft(this.value, this.left);
  BinaryTree.withRight(this.value, this.right);
  BinaryTree.withChildren(this.value, this.left, this.right);

  int value;
  BinaryTree? left;
  BinaryTree? right;
}
