import Int "mo:base/Int";
import Array "mo:base/Array";

actor {
    public func greet(name : Text) : async Text {
        return "Hello, " # name # "!";
    };

    /*
     * 快速排序算法。
     */
    public query func qsort(xs : [Int]) : async [Int] {
        return quicksort(xs);
    };

    private func quicksort(arr : [Int]) : [Int] {
        if (arr.size() < 2) arr else {
            let result = Array.thaw<Int>(arr);
            sortCalls(result, 0, arr.size() - 1);
            return Array.freeze<Int>(result);
        }
    };

    private func sortCalls(
        arr : [var Int],
        leftValue : Int,
        rightValue : Int,
    ) {
        if (leftValue < rightValue) {
            var i = leftValue;
            var j = rightValue;
            var swap  = arr[0];
            let pivot = arr[Int.abs(leftValue + rightValue) / 2];
            while (i <= j) {
                while (arr[Int.abs(i)] < pivot) {
                    i += 1;
                };
                while (arr[Int.abs(j)] > pivot) {
                    j -= 1;
                };
                if (i <= j) {
                    swaparr(arr,i,j);
                    i += 1;
                    j -= 1;
                };
            };
            if (leftValue < j) {
                sortCalls(arr, leftValue, j);
            };
            if (i < rightValue) {
                sortCalls(arr, i, rightValue);
            };
        };
    };

    private func swaparr(
        arr : [var Int],
        a : Int,
        b : Int,
    ) {
        var swap = arr[Int.abs(a)];
        arr[Int.abs(a)] := arr[Int.abs(b)];
        arr[Int.abs(b)] := swap;
    }
};
