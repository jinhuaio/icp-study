actor {
    public func greet(name : Text) : async Text {
        return "Hello, " # name # "!";
    };

    type TA = {
        a : Bool;
    };

    type TAB = {
        a : Bool;
        b : Nat;
    };

    type T0 = {};

    type RB = {
        #red; #blue
    };

    type RBY = {
        #red; #yellow; #blue
    };

    type Gender = {
        #male; #female
    };

    /**
    判断下述子类型关系是否为真
    {a: Bool} <= {a : Bool; b : Nat}  ——》 false : type error
    {a: Bool} <= {} ——》 true
    {#red; #blue} <= {#red; #yellow; #blue} ——》 true
    Nat <= Int ——》 true
    Int <= Int32 ——》false
    () -> () <= (Text) -> () ——》false : type error
    () -> () <= () -> () ——》 true
    () -> ({#male; #female}) <= () -> () ——》false : type error
    (Int) -> (Nat) <= (Nat) -> (Int) ——》 true
    (Int16, Nat8) <= (Int32, Nat32) ——》false : type error
    **/
    public func testSubtype() : async Bool{
        //1: {a: Bool} <= {a : Bool; b : Nat}  ——》 false : type error
        var ta : TA = {a = true};
        var tab : TAB = {a = true;b = 1};
        //tab := ta; // false : type error , ta := tab; is true

        //2: {a: Bool} <= {} ——》 true
        var t0 : T0 = {};
        t0 := ta; // true

        //3: {#red; #blue} <= {#red; #yellow; #blue} ——》 true
        var rb : RB = #red;
        var rby : RBY = #red;
        rby := rb; // true

        //4: Nat <= Int ——》 true
        var nat1 : Nat = 1;
        var int1 : Int = 1;
        int1 := nat1; // true

        //5: Int <= Int32 ——》false
        var int32 : Int32 = 1;
        // int32 := nat1; // false 

        //6: () -> () <= (Text) -> () ——》false : type error
        var f1 : () -> () = func ()  {};
        var f2 : (Text) -> () = func (t : Text) {};
        // f2 := f1; //  ——》false : type error

        //7: () -> () <= () -> () ——》 true
        var f3 : () -> () = func () {};
        var f4 : () -> () = func () {};
        f4 := f3; //  true

        //8: () -> ({#male; #female}) <= () -> () ——》false : type error
        var f5 : () -> (Gender) = func () : Gender {#male};
        var f6 : () -> () = func () {};
        // f6 := f5; //  false

        //9: (Int) -> (Nat) <= (Nat) -> (Int) ——》 true
        var fa : (Int) -> (Nat) = func (i : Int) : Nat {1};
        var fb : (Nat) -> (Int) = func (i : Nat) : Int {-1};
        fb := fa; //——》 true
        // 函数的子类型赋值关系：
        // a: 被赋值变量（fb）的函数返回参数类型（Int） 必须比 赋值变量(fa)的函数返回参数类型(Nat) 要宽泛（或至少要等于）
        // b: 入参数量必须一致，不能多也不能少
        // c: 入参的数据类型宽泛程度恰好与返回值的要求相反，即：赋值变量（fa）的函数入参数类型（Int） 必须比 被赋值变量(fb)的函数返回参数类型(Nat) 要宽泛（或至少要等于）


        //10: (Int16, Nat8) <= (Int32, Nat32) ——》false : type error
        let int16 : Int16 = 1;
        // let int32 : Int32 = 1;
        let nat8 : Nat8 = 1;
        let nat32 : Nat32 = 1; 
        var t1 : (Int16, Nat8) = (int16, nat8);
        var t2 : (Int32, Nat32) = (int32, nat32);
        // t2 := t1;  // false : type error

        true;
    };

    
};
