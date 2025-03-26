import Foundation

final class DummyJSONAPIClient: JWTAPIClient {
    var baseURL: URL {
        URL(string: "https://dummyjson.com/")!
    }
    
    var jwt: String?
    
    func auth(with credentials: Credentials, completion: @escaping (Result<Void, NetworkError>) -> Void) -> URLSessionTask {
        var url = baseURL
        url.appendPathComponent("auth/login")
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.POST.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try? JSONEncoder().encode(credentials)
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error {
                completion(.failure(.dataTaskError(error)))
                
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.systemError("Response is not a HTTPURLResponse")))
                return
            }
            
            guard 200..<299 ~= httpResponse.statusCode else {
                completion(.failure(.httpError(httpResponse.statusCode)))
                return
            }
            
            guard let data else {
                completion(.failure(.emptyData))
                
                return
            }
            
            guard let authResponse = try? JSONDecoder().decode(AuthResponse.self, from: data) else {
                completion(.failure(.decodingError("Failed to decode AuthResponse")))
                
                return
            }
            
            self?.jwt = authResponse.accessToken
            
            completion(.success(()))
        }
        
        task.resume()
        
        return task
    }
    
    func request(from endpoint: any Endpoint, completion: @escaping (Result<Data?, NetworkError>) -> Void) -> URLSessionTask {
        var url = baseURL
        url.appendPathComponent(endpoint.path)
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let jwt = jwt {
            request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                completion(.failure(.dataTaskError(error)))
                
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.systemError("Response is not a HTTPURLResponse")))
                return
            }
            
            guard 200..<299 ~= httpResponse.statusCode else {
                completion(.failure(.httpError(httpResponse.statusCode)))
                return
            }
            
            completion(.success(data))
        }
        
        task.resume()
        
        return task
    }
    
    
}
