enum LoadResult<T> {
    case loading
    case loaded(T)
    case failed(Error)

    func described(by describe: (T) -> String) -> String {
        switch self {
        case .loading:
            return "..."
        case .loaded(let value):
            return describe(value)
        case .failed(let error):
            return error.localizedDescription
        }
    }

    func map<U>(transform: (T) -> U) -> LoadResult<U> {
        switch self {
        case .loaded(let value):
            return .loaded(transform(value))
        case .loading:
            return .loading
        case .failed(let error):
            return .failed(error)
        }
    }
}
