/// Generic, extensible buffers
///
/// Generic, mutable sequences that grow to accommodate arbitrary numbers of elements.
///
/// Class `Buffer<X>` provides extensible, mutable sequences of elements of type `X`.
/// that can be efficiently produced and consumed with imperative code.
/// A buffer object can be extended by a single element or the contents of another buffer object.
///
/// When required, the current state of a buffer object can be converted to a fixed-size array of its elements.
///
/// Buffers complement Motoko's non-extensible array types
/// (arrays do not support efficient extension, because the size of an array is
/// determined at construction and cannot be changed).

import Prim "mo:⛔";
import Int       "mo:base/Int";
import Nat       "mo:base/Nat";
import Array     "mo:base/Array";
import Iter      "mo:base/Iter";


module {

  /// Create a stateful buffer class encapsulating a mutable array.
  ///
  /// The argument `initCapacity` determines its initial capacity.
  /// The underlying mutable array grows by doubling when its current
  /// capacity is exceeded.
  public class ExtBuffer<X>(initCapacity : Nat) {
    var count : Nat = 0;
    var elems : [var X] = [var]; // initially empty; allocated upon first `add`

    /// Adds a single element to the buffer.
    public func add(elem : X) {
      if (count == elems.size()) {
        let size =
          if (count == 0) {
            if (initCapacity > 0) { initCapacity } else { 1 }
          } else {
            2 * elems.size()
          };
        let elems2 = Prim.Array_init<X>(size, elem);
        var i = 0;
        label l loop {
          if (i >= count) break l;
          elems2[i] := elems[i];
          i += 1;
        };
        elems := elems2;
      };
      elems[count] := elem;
      count += 1;
    };

    /// Removes the item that was inserted last and returns it or `null` if no
    /// elements had been added to the Buffer.
    public func removeLast() : ?X {
      if (count == 0) {
        null
      } else {
        count -= 1;
        ?elems[count]
      };
    };

    /// Adds all elements in buffer `b` to this buffer.
    public func append(b : ExtBuffer<X>) {
      let i = b.vals();
      loop {
        switch (i.next()) {
          case null return;
          case (?x) { add(x) };
        };
      };
    };

    public func appendArray(array : [X]) {
      for (a in Iter.fromArray(array)) {
        add(a);
      };
    };

    /// Returns the current number of elements.
    public func size() : Nat =
      count;

    /// Resets the buffer.
    public func clear() =
      count := 0;

    /// Returns a copy of this buffer.
    public func clone() : ExtBuffer<X> {
      let c = ExtBuffer<X>(elems.size());
      var i = 0;
      label l loop {
        if (i >= count) break l;
        c.add(elems[i]);
        i += 1;
      };
      c
    };

    /// Returns an `Iter` over the elements of this buffer.
    public func vals() : { next : () -> ?X } = object {
      var pos = 0;
      public func next() : ?X {
        if (pos == count) { null } else {
          let elem = ?elems[pos];
          pos += 1;
          elem
        }
      }
    };

    /// Creates a new array containing this buffer's elements.
    public func toArray() : [X] =
      // immutable clone of array
      Prim.Array_tabulate<X>(
        count,
        func(x : Nat) : X { elems[x] }
      );
    
    public func subArray(from : ?Nat,to : ?Nat) : [X] {
      let size : Nat = count;
      if (size == 0) {
        return [];
      };
      let fromIndex = switch(from) { 
        case null {0}; 
        case (?n) { if (n >= size){ Int.abs(size - 1)} else {n};};
        };
      let toIndex = switch(to) { case null {Int.abs(size - 1)}; case (?n) {if (n >= size){ Int.abs(size - 1)} else {n};}};
      let subCount = Int.abs(toIndex - fromIndex) + 1;
      var elems2 = Prim.Array_init<X>(subCount, elems[fromIndex]);
      var i = 0;
      label tt loop {
        if (i >= subCount) break tt;
        elems2[i] := elems[fromIndex + i];
        i += 1;
      };
      Array.freeze<X>(elems2);
    };

    /// Creates a mutable array containing this buffer's elements.
    public func toVarArray() : [var X] {
      if (count == 0) { [var] } else {
        let a = Prim.Array_init<X>(count, elems[0]);
        var i = 0;
        label l loop {
          if (i >= count) break l;
          a[i] := elems[i];
          i += 1;
        };
        a
      }
    };

    /// Gets the `i`-th element of this buffer. Traps if  `i >= count`. Indexing is zero-based.
    public func get(i : Nat) : X {
      assert(i < count);
      elems[i]
    };

    /// Gets the `i`-th element of the buffer as an option. Returns `null` when `i >= count`. Indexing is zero-based.
    public func getOpt(i : Nat) : ?X {
      if (i < count) {
        ?elems[i]
      }
      else {
        null
      }
    };

    /// Overwrites the current value of the `i`-entry of  this buffer with `elem`. Traps if the
    /// index is out of bounds. Indexing is zero-based.
    public func put(i : Nat, elem : X) {
      elems[i] := elem;
    };
  };

}
