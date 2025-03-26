import Foundation

protocol JWTAPIClient {
    var baseURL: URL { get }
    var jwt: String? { get }
    
    func auth(with credentials: Credentials, completion: @escaping (Result<Void, NetworkError>) -> Void) -> URLSessionTask
    
    func request(from endpoint: Endpoint, completion: @escaping (Result<Data?, NetworkError>) -> Void) -> URLSessionTask
}

struct Credentials: Codable {
    var username: String
    var password: String
}
