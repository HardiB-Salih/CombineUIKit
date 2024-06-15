//
//  HomeVC.swift
//  CombineUIKit
//
//  Created by HardiB.Salih on 6/15/24.
//

import UIKit
import SwiftUI
import Combine

class HomeVC: UIViewController {
    
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.layer.masksToBounds = true
        searchBar.delegate = self
        return searchBar
    }()
        
    lazy var moviesTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false

        return tableView
    }()
    
    let homeViewModel: HomeViewModel
    private var cancellables : Set<AnyCancellable> = []
    
    init(homeViewModel: HomeViewModel) {
        self.homeViewModel = homeViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    
    private let navTitle = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        

        
        homeViewModel.$loadingCompleted
            .receive(on: DispatchQueue.main)
            .sink { [ weak self ] completed in
                if completed {
                    self?.moviesTableView.reloadData()
                }
            }.store(in: &cancellables)
    }

    
    private func setupUI() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = .systemBackground
        
        // register cells
        moviesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MovieTableViewCell")
        
        view.addSubview(navTitle)
        navTitle.text = "Movies"
        
        navTitle.font = .systemFont(of: .callout, weight: .bold)
        navTitle.anchor(top: view.safeAreaLayoutGuide.topAnchor)
        navTitle.centerX(inView: view)

        view.addSubview(searchBar)
        searchBar.anchor(top: navTitle.bottomAnchor , left: view.leftAnchor, right: view.rightAnchor, paddingTop: 8, paddingLeft: 16, paddingRight: 16)
        
        view.addSubview(moviesTableView)
        moviesTableView.anchor(top: searchBar.bottomAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor)
    }


}


//MARK :  UITableViewDelegate && UITableViewDataSource
extension HomeVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return homeViewModel.movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieTableViewCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        let movie = homeViewModel.movies[indexPath.row]
        content.text = movie.title
        cell.contentConfiguration = content
        return cell
    }
}

extension HomeVC : UISearchBarDelegate { 
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        homeViewModel.setSerchText(searchText)
    }
}
