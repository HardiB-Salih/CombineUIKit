//
//  HTTPClient.swift
//  CombineUIKit
//
//  Created by HardiB.Salih on 6/15/24.
//


import Foundation
import Combine

enum NetworkError: Error {
    case badURL
    case requestFailed(Error)
    case decodingFailed(Error)
}
class HTTPClient {
    let API_KEY = "API_KEY"
    
    /// Fetches a list of movies matching the search query.
    ///
    /// This function returns a publisher that emits an array of `Movie` objects or an error.
    /// The search query is used to filter the movies based on their titles or other relevant criteria.
    ///
    /// - Parameter search: A `String` representing the search query to filter movies.
    /// - Returns: An `AnyPublisher` that emits an array of `Movie` objects on success, or an `Error` on failure.
    ///
    /// Example usage:
    /// ```swift
    /// let searchQuery = "Inception"
    /// let moviePublisher = fetchMovies(search: searchQuery)
    /// moviePublisher
    ///     .sink(receiveCompletion: { completion in
    ///         switch completion {
    ///         case .finished:
    ///             print("Finished fetching movies")
    ///         case .failure(let error):
    ///             print("Failed to fetch movies: \(error)")
    ///         }
    ///     }, receiveValue: { movies in
    ///         print("Fetched movies: \(movies)")
    ///     })
    ///     .store(in: &cancellables)
    /// ```
    func fetchMovies(search: String) -> AnyPublisher<[Movie], Error> {
        guard let encodedSearch = search.urlEncoded else {
            return Fail(error: NetworkError.badURL).eraseToAnyPublisher()
        }
        
        let urlString = "https://api.themoviedb.org/3/search/movie?query=\(encodedSearch)&include_adult=false&language=en-US&page=1"
        guard let url = URL(string: urlString) else {
            return Fail(error: NetworkError.badURL).eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(API_KEY)", forHTTPHeaderField: "Authorization")
        

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: MovieResponse.self, decoder: JSONDecoder())
            .map { $0.results }
            .mapError { error in
                if let decodingError = error as? DecodingError {
                    return NetworkError.decodingFailed(decodingError)
                }
                return NetworkError.requestFailed(error)
            }
            .eraseToAnyPublisher()
    }

}



