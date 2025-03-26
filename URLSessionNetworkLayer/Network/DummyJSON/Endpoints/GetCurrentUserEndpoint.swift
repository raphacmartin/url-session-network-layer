struct GetCurrentUserEndpoint { }

extension GetCurrentUserEndpoint: Endpoint {
    var path: String { "auth/me" }
    var method: HTTPMethod { .GET }
}
