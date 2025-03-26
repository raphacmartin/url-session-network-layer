import Foundation

final class UserService: NetworkService {
    var apiClient: JWTAPIClient
    
    init(apiClient: JWTAPIClient = DummyJSONAPIClient()) {
        self.apiClient = apiClient
    }
}

// MARK: Endpoints
extension UserService {
    func currentUser(completion: @escaping (Result<UserResponse, NetworkError>) -> Void) -> URLSessionTask{
        let endpoint = GetCurrentUserEndpoint()
        
        let task = apiClient.request(from: endpoint) { [weak self] result in
            switch result {
                
            case .success(let data):
                guard let self else {
                    completion(.failure(.systemError("Nil self in UserService.currentUser")))
                    
                    return
                }
                
                guard let data else {
                    completion(.failure(.emptyData))
                    
                    return
                }
                
                guard let userResponse = self.decodeUser(from: data) else {
                    completion(.failure(.decodingError("Failed to decode UserResponse")))
                    
                    return
                }
                
                completion(.success(userResponse))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        task.resume()
        
        return task
    }
}

// MARK: Decoding
extension UserService {
    private func decodeUser(from data: Data) -> UserResponse? {
        do {
            let decoder = JSONDecoder()
            
            return try decoder.decode(UserResponse.self, from: data)
        } catch {
            print("Failed to decode user: \(error)")
            return nil
        }
    }
}
