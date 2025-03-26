import Foundation
import Testing

@testable import URLSessionNetworkLayer

@Test("Test that calling the auth endpoint stores the JWT") func testAuth() async throws {
    let apiClient = DummyJSONAPIClient()
    let credentials = Credentials(username: "emilys", password: "emilyspass")
    
    await withCheckedContinuation { continuation in
        let _ = apiClient.auth(with: credentials) { result in
            if case .success = result {
                #expect(apiClient.jwt != nil)
            } else {
                Issue.record("Authentication Failed")
            }
            
            continuation.resume()
        }
    }
}

@Test("Test that fetching current user before authentication returns error") func testCurrentUserBeforeAuth() async throws {
    let apiClient = DummyJSONAPIClient()
    
    let userService = UserService(apiClient: apiClient)
    await withCheckedContinuation { continuation in
        // Fetching the current user before authenticating
        let _ = userService.currentUser { result in
            guard case let .failure(error) = result else {
                Issue.record("Network call unexpectedly succeeded")
                continuation.resume()
                return
            }
            
            guard case let .httpError(statusCode) = error else {
                Issue.record("Network call failed with an unexpected error: \(error)")
                continuation.resume()
                return
            }
            
            // Checking if the response is "Unauthorized"
            #expect(statusCode == 401)
            
            continuation.resume()
        }
    }
    
}

@Test("Test that fetching current user after authentication returns the user")
func testCurrentUserAfterAuth() async throws {
    let apiClient = DummyJSONAPIClient()
    let credentials = Credentials(username: "emilys", password: "emilyspass")

    // Authenticating first
    await withCheckedContinuation { continuation in
        let _ = apiClient.auth(with: credentials) { result in
            guard case .success = result else {
                Issue.record("Authentication Failed")
                continuation.resume()
                return
            }
            
            continuation.resume()
        }
    }
    
    let userService = UserService(apiClient: apiClient)
    await withCheckedContinuation { continuation in
        // Fetching the current user after being authenticated
        let _ = userService.currentUser { result in
            guard case .success(let user) = result else {
                Issue.record("Network call failed")
                continuation.resume()
                return
            }

            #expect(user.id == 1)
            #expect(user.firstName == "Emily")
            continuation.resume()
        }
    }
}
