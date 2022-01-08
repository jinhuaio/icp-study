import Int "mo:base/Int";
import Heapsort "Heapsort";

actor {
    public func greet(name : Text) : async Text {
        return "Hello, " # name # "!";
    };

    /*
     * 堆排序算法。
     */
    public query func heapsort(xs : [Int]) : async [Int] {
        return Heapsort.sortBy(xs, Int.compare);
    };

};
