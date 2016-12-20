import Foundation

class User:NSObject {
    var name: String = ""
    var age: Int = 0
    var married: Bool = false
    var birthday: Date?
    var sex: Int = 0
}

HproseClassManager.registerClass(User.self, withAlias: "User")
var client = HproseHttpClient("http://www.hprose.com/example/index.php")!

var result = client.asyncInvoke("hello", withArgs: ["async world"])

result.done( { (result) in
    print(result!);
}, fail: {
    (e) in
    print(e!);
});

print(client.invoke("hello", withArgs: ["sync world"]));

var sexStrings = ["Unknown", "Male", "Female", "InterSex"];

var users = client.invoke("getUserList") as! [User];
for user in users {
    print(user.name);
    print(user.age);
    print(user.married);
    print(user.birthday!);
    print(sexStrings[user.sex]);
}

@objc protocol Hello {
    func hello(_ name:String, _ callback: HproseCallback, _ errorBlock: HproseErrorCallback) -> Void
    func hello(_ name:String) -> String
    func sum(_ a:Int, _ b:Int, _ c:Int) -> NSNumber
    func swapKeyAndValue(_ dict: [String: String]) -> [String: String]
    func getUserList() -> Array<User>;
}

var proxy = client.useService(Hello.self) as AnyObject;

proxy.hello("async world", {(result, args) in
    print(result!);
}, { (name, error) in
    print(error!)
})

print(proxy.hello("sync world"));

print(proxy.sum(1, 2, 3))

print(proxy.swapKeyAndValue(["January": "Jan", "February": "Feb", "March": "Mar", "April": "Apr"]))

var userList = proxy.getUserList();
for user in userList {
    print(user.name);
    print(user.age);
    print(user.married);
    print(user.birthday!);
    print(sexStrings[user.sex]);
}
