import Int "mo:base/Int";
import Nat "mo:base/Nat";
import Text "mo:base/Text";

actor {

    stable var counter = 0;

    // Get the value of the counter.
    public query func getCounter() : async Nat {
        return counter;
    };

    // Set the value of the counter.
    public func setCounter(n : Nat) : async Nat {
        counter := n;
        counter;
    };

    // Increment the value of the counter.
    public func incCounter() : async () {
        counter += 1;
    };

    public type StreamingCallbackHttpResponse = {
        token : ?StreamingCallbackToken;
        body : [Nat8];
    };

    public type StreamingCallbackToken = {
        key : Text;
        sha256 : ?[Nat8];
        index : Nat;
        content_encoding : Text;
    };
    
    public type StreamingStrategy = {
        #Callback : {
        token : StreamingCallbackToken;
        callback : shared query StreamingCallbackToken -> async StreamingCallbackHttpResponse;
        };
    };

    public type HeaderField = (Text, Text);
    public type HttpRequest = {
        url : Text;
        method : Text;
        body : [Nat8];
        headers : [HeaderField];
    };
    public type HttpResponse = {
        body : Blob;
        headers : [HeaderField];
        streaming_strategy : ?StreamingStrategy;
        status_code : Nat16;
    };

    

    public shared query func http_request(request: HttpRequest) : async HttpResponse {
        {
            body = Text.encodeUtf8(
                "<!DOCTYPE html><html lang=\"zh-cn\"><head><meta charset=\"utf-8\" /> </head> "
                # "<body> Hi ~! 我是86号学员，当前计数器《后端》值为： "# Nat.toText(counter) #" <br> 跳转到计数器 <a href=\"https://a4gq6-oaaaa-aaaab-qaa4q-cai.raw.ic0.app/?id=4zwbv-2yaaa-aaaak-qadga-cai\">《Candid_UI》，请点击这 </a> <br> 跳转到计数器 <a href=\"https://46xhb-xaaaa-aaaak-qadgq-cai.ic0.app\">《前端UI》，请点击这 </a> </body></html>"
            );
            headers = [];
            streaming_strategy = null;
            status_code = 200;
        }
    }
    
};
