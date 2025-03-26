enum NetworkError: Error {
    case dataTaskError(Error)
    case systemError(String)
    case emptyData
    case decodingError(String)
    case httpError(Int)
}
