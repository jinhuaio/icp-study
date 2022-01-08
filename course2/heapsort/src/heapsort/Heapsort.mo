import Array "mo:base/Array";
import Order "mo:base/Order";
import Int "mo:base/Int";
import Debug "mo:base/Debug"

module Heapsort {

  type Order = Order.Order;

  // Sort the elements of an array using the given comparison function.
  public func sortBy<X>(xs : [X], f : (X, X) -> Order) : [X] {
    let n = xs.size();
    if (n < 2) {
      return xs;
    } else {
      let result = Array.thaw<X>(xs);
      topMaxHeapSort<X>(result, f);
      return Array.freeze<X>(result);
    };
  };

  /*
   * 最大顶堆排序
   * 
   */
  private func topMaxHeapSort<X>(xs : [var X], f : (X, X) -> Order) {
    // 先创建最大顶堆
    createTopMaxHeap<X>(xs,f);
    // Debug.print("创建完毕");
    var end : Int = xs.size() - 1;
    while (end > 0) {
      // 把0位的最大值放到最后
      swaparr<X>(xs ,0, end);
      // 将计算的长度减一.不考虑最后的那个值
      end := end - 1;
      handleMaxHeapFromIndex<X>(xs, 0, end,f);
    };
    // 打印下看看
    // System.out.println(Arrays.toString(a));
  };
  /*
   * [3,7,1,4,9,5,6,7,2,6,8,3]
   * `````````3
   * ``````/     \
   * `````7       1
   * ````/ \     / \
   * ``4   9   5   6
   * `/ \ / \ /
   * `7 2 6 8 3
   * 变成 [9, 8, 6, 7, 7, 5, 1, 4, 2, 6, 3, 3]
   * `````````9
   * ```````/    \
   * `````8       6
   * ````/ \     / \
   * ``7   7   5   1
   * `/ \ / \ /
   * `4 2 6 3 3
   * 构建最大顶堆, 变成父节点都比子节点大的树
   * @param a
   *
   */
  private func createTopMaxHeap<X>(xs : [var X], f : (X, X) -> Order) {
    // 从倒数第二排最后一个开始, 从下往上, 层层处理把最大的换上去构建最大顶堆
    // 如上面的注释, 就是从5开始. 再往后就没意义了
    var i : Int = (xs.size() - 1) / 2;
    while (i >= 0) {
      handleMaxHeapFromIndex<X>(xs, i, xs.size() - 1,f);
      i -= 1;
    };
  };

  private func handleMaxHeapFromIndex<X>(xs : [var X], i : Int, end : Int, f : (X, X) -> Order) {
    // 从i开始往后面调整它的堆
    // 左子节点, 右子节点
    // 设置一个用于玩下遍历和判断的子节点, 默认就是左边的儿子
    var child : Int = 2 * i + 1;
    var ii = i;
    while (child <= end) {
      // 如果右子节点比左边大
      var leftson : Int = child;
      var rightson : Int = child + 1;
      if (rightson <= end and Order.isGreater(f(xs[Int.abs(rightson)], xs[Int.abs(leftson)]))) {
        // 就设置为右边的儿子
        child += 1;
      };
      // 再比较父子,如果儿子比父亲大,就互换
      if (Order.isLess(f(xs[Int.abs(ii)],xs[Int.abs(child)]))) {
        swaparr<X>(xs, ii, child);
      } else {
        // 否则直接跳出循环, 只要父节点比子节点大, 不用管下面的调整了
        return;
      };
      // 继续循环
      ii := child;
      // 继续选择它的左儿子
      child := 2 * ii + 1;
    };
  };

  private func swaparr<X>(
    xs : [var X],
    a : Int,
    b : Int,
  ) {
    var swap = xs[Int.abs(a)];
    xs[Int.abs(a)] := xs[Int.abs(b)];
    xs[Int.abs(b)] := swap;
  }
};
