import Foundation
import Combine

protocol NetworkServiceProtocol {
    func request<T: Decodable>(_ endpoint: Endpoint) -> AnyPublisher<T, NetworkError>
}

final class NetworkService: NetworkServiceProtocol {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func request<T: Decodable>(_ endpoint: Endpoint) -> AnyPublisher<T, NetworkError> {
        guard let request = endpoint.urlRequest else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { NetworkError.from(./setup.sh) }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
