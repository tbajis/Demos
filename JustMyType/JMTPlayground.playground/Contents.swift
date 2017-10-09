//: # Just My Type!
//: ## Types and Errors in Swift
import Foundation

// MARK: - Datasource
let teamNames = ["Tommy": "Enterprise", "Samantha": "Columbia", "Patricia": "Challenger", "Maria": "Discovery", "Demo": "Endeavour", "Roger": "Atlas"]
let teamMembers = ["Enterprise": 5, "Columbia": 6, "Challenger": 3, "Discovery": 8, "Endeavour": 4]
//: ### Example 1: Using an Optional Return Type
//: Below is a function that given a team member's `memberName` will return an optional number of people (`Int?`) on that team.
func numberOfTeamMembers(memberName: String) -> Int? {
    guard let team = teamNames[memberName] else { return nil }
    guard let number = teamMembers[team] else { return nil }
    return number
}

let someLookup = numberOfTeamMembers(memberName: "Tommy")
let someOtherLookup = numberOfTeamMembers(memberName: "Dan")
//: The `someLookup` is assigned the number of members on Tommy's team. However, the `someOtherLookup` contains `nil` because an unknown team member (Dan) was checked. While this may seem like a reasonable approach to searching through our Datasource, the unsuccessful case provides no information as to the specific error that caused the lookup to fail.
//: ### Example 2: Enter Enumerations
//: To improve on the shortcomings of the previous example, a `NumberResult` enumeration is defined with associated types `Int` and `LookupError` corresponding to a `success` and `failure` respectively. Now we can distinguish between both possible errors in our function.
enum LookupError: Error {
    case teamMemberNotFound
    case numberOfMembersNotFound
}

enum NumberResult {
    case success(Int)
    case failure(LookupError)
}

func numberOfTeamMembers2(memberName: String) -> NumberResult {
    guard let team = teamNames[memberName] else { return .failure(.teamMemberNotFound) }
    guard let number = teamMembers[team] else { return .failure(.numberOfMembersNotFound) }
    return .success(number)
}

let someLookup2 = numberOfTeamMembers2(memberName: "Tommy")
let someOtherLookup2 = numberOfTeamMembers2(memberName: "Dan")
//: In the case of failure, `numberOfTeamMembers2(memberName:)` will pass along an error corresponding to the failed check. Likewise, an `Int` wll be passed along in the case of success. This behavior is desired over the previous example. Although this example is simple, it illustrates how beneficial custom types can be when error handling.
//: ### Example 3: Enter Generics
//: We should consider using generics to make the previous example more reusable. By using generics in our code, we can allow for a more generalized return value. Defined below is a `Result<T>` enumeration that can be used to represent both our success of associated type `T` and failure of associated type `LookupError`.
enum Result<T> {
    case success(T)
    case failure(LookupError)
}
//: We could implement `Result<T>` in our function like this:
func numberOfTeamMembers3(memberName: String) -> Result<Int> {
    guard let team = teamNames[memberName] else { return .failure(.teamMemberNotFound) }
    guard let number = teamMembers[team] else { return .failure(.numberOfMembersNotFound) }
    return .success(number)
}
//: Using `Result<T>` is very useful here since it can be used for any successful return type `T`.
//: ### Example 4: A Note on Swift's Error Handling
//: Swift's built-in error handling system is configured similarly to the `Result<T>` type we've defined above. However, Swift forces you to mark any function that might throw an error with the `throws` keyword. It also forces you to `try` when calling this code. A limitation of this mechanism is that it only works on the result type of the function. Using this pattern in our example might look something like this:
func numberOfTeamMembers4(memberName: String) throws -> Int {
    guard let team = teamNames[memberName] else { throw LookupError.teamMemberNotFound }
    guard let number = teamMembers[team] else { throw LookupError.numberOfMembersNotFound }
    return number
}
//: To call this in our code, we could wrap the call and success flows in a `do` block and handle errors in a `catch`
do {
    let numberOfMembers = try numberOfTeamMembers4(memberName: "Patricia")
    print("Patricia's team has \(numberOfMembers) member(s).")
    // handle rest of success flow here
} catch {
    print("Lookup error: \(error)")
    // handle error flow here
}
//: The `numberOfTeamMembers4(memberName:)` above simply returns an `Int` if the checks are completed successfully. However, we could also modify our `Result` enumeration from above like so:
enum NewResult<T, SomeError: Error> {
    case success(T)
    case failure(SomeError)
}
//: The `NewResult<T, SomeError: Error>` type could be used as a return type for a function returning any value `T` and any error `SomeError` (so long as `SomeError` conforms to the `Error` protocol). We could apply this new result type to our previous examples like so:
func newLookup(memberName: String) -> NewResult<Int, LookupError> {
    guard let team = teamNames[memberName] else { return .failure(.teamMemberNotFound) }
    guard let number = teamMembers[team] else { return .failure(.numberOfMembersNotFound) }
    return .success(number)
}
//: In code, we can now simply `switch` on the result of `newLookup(memberName:)` and handle the `success` and `failure` cases.
let teamMembersResult = newLookup(memberName: "Samantha")

switch teamMembersResult {
case .success(let number):
    print("Samantha has \(number) member(s) on her team.")
// handle success flow here
case .failure(let error):
    print("An error: \(error.localizedDescription) occured!")
    // handle failure flow here
}
//: Switching on `teamMembersResult` to handle success and failure cases makes for cleaner, more intuitive error handling.
