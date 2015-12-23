import Foundation

class User:NSObject {
    var name: String = ""
    var age: Int = 0
    var married: Bool = false
    var birthday: NSDate?
    var sex: Int = 0
}

@objc protocol Hello {
    func hello(name:String) -> String
    func sum(a:Int, b:Int, c:Int) -> Int
    func swapKeyAndValue(dict: [String: String]) -> [String: String]
    func getUserList() -> Array<User>;
}

HproseClassManager.registerClass(User.self, withAlias: "User")
var client = HproseHttpClient("http://www.hprose.com/example/index.php")
var h: AnyObject! = client.useService(Hello)
print(h.hello("world"))
print(h.hello("hprose"))
print(h.hello("中文"))
print(h.sum(1,b:2,c:3))
print(h.swapKeyAndValue(["January": "Jan", "February": "Feb", "March": "Mar", "April": "Apr"]));
var sexStrings = ["Unknown", "Male", "Female", "InterSex"];
var users = h.getUserList();
for user in users {
    print(user.name)
    print(user.age)
    print(user.married)
    print(user.birthday)
    print(sexStrings[user.sex])
}
