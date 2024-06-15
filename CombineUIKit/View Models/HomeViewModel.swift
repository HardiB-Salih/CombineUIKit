//
//  HomeViewModel.swift
//  CombineUIKit
//
//  Created by HardiB.Salih on 6/15/24.
//

import Foundation
import Combine

/// ViewModel for handling movie data and search functionality in the Home view.
class HomeViewModel {
    /// A published array of `Movie` objects.
    @Published private(set) var movies: [Movie] = []
    
    /// A published boolean indicating whether the loading of movies is completed.
    @Published var loadingCompleted: Bool = false
    
    /// A set to store cancellable references for Combine publishers.
    private var cancellables: Set<AnyCancellable> = []
    
    /// A subject to manage the search text input.
    private var searchSubject = CurrentValueSubject<String, Never>("")
    
    /// An instance of `HTTPClient` to handle network requests.
    private let httpClient: HTTPClient
    
    /// Initializes a new instance of `HomeViewModel`.
    ///
    /// - Parameter httpClient: An instance of `HTTPClient` for fetching movies.
    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
        setupSearchPublisher()
    }
    
    /// Sets up the publisher to handle debounced search text changes.
    ///
    /// This function configures the `searchSubject` to debounce the input and call `loadMovies(search:)`
    /// with the debounced search text.
    private func setupSearchPublisher() {
        searchSubject
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { [weak self] searchText in
                self?.loadMovies(search: searchText)
            }
            .store(in: &cancellables)
    }
    
    /// Updates the search text for movie search.
    ///
    /// - Parameter searchText: The new search text to filter movies.
    func setSerchText(_ searchText: String) {
        searchSubject.send(searchText)
    }
    
    /// Loads movies based on the provided search text.
    ///
    /// This function fetches movies from the `HTTPClient` and updates the `movies` array.
    /// It also sets `loadingCompleted` to `true` upon successful completion.
    ///
    /// - Parameter search: A `String` representing the search query to filter movies.
    func loadMovies(search: String) {
        httpClient.fetchMovies(search: search)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case .finished:
                    self.loadingCompleted = true
                    print("Finished fetching movies")
                case .failure(let error):
                    print("Failed to fetch movies: \(error)")
                }
            }, receiveValue: { [weak self] movies in
                guard let self = self else { return }
                self.movies = movies
            })
            .store(in: &cancellables)
    }
}
