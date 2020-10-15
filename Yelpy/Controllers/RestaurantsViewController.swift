//
//  ViewController.swift
//  Yelpy
//
//  Created by Memo on 5/21/20.
//  Copyright © 2020 memo. All rights reserved.
//

import UIKit
import AlamofireImage
import Lottie
import SkeletonView

class RestaurantsViewController: UIViewController {
    
    // Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    // Initiliazers
    var restaurantsArray: [Restaurant] = []
    var filteredRestaurants: [Restaurant] = []
    
    // –––––  Lab 4: create an animation view
    var animationView: AnimationView?
    var refresh = true
    
    var refreshControl: UIRefreshControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // ––––– Lab 4 TODO: Start animations
        startAnimation()
        
        // Table View
        tableView.delegate = self
        tableView.dataSource = self
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
        // Search Bar delegate
        searchBar.delegate = self
        
        // Get Data from API
        getAPIData()
        
        // –––––  Lab 4: stop animations, you can add a timer to stop the animation
        perform(#selector(stopAnimation), with: nil, afterDelay: 1)
        
    }
    
    @objc func getAPIData() {
        API.getRestaurants() { (restaurants) in
            guard let restaurants = restaurants else {
                return
            }
            self.restaurantsArray = restaurants
            self.filteredRestaurants = restaurants
            self.tableView.reloadData()
            
        }
    }
    
    @objc func onRefresh() {
        startAnimation()
        getAPIData()
        perform(#selector(stopAnimation), with: nil, afterDelay: 1)
        self.refreshControl.endRefreshing()
    }
    
}

// ––––– TableView Functionality –––––
extension RestaurantsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredRestaurants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Create Restaurant Cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantCell") as! RestaurantCell
        // Set cell's restaurant
        cell.r = filteredRestaurants[indexPath.row]
        if (self.refresh){
            cell.showAnimatedSkeleton()
        }else{
            cell.hideSkeleton()
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UITableViewCell
        if let indexPath = tableView.indexPath(for: cell) {
            let r = filteredRestaurants[indexPath.row]
            let detailViewController = segue.destination as! RestaurantDetailViewController
            detailViewController.r = r
        }
        
    }

}

extension RestaurantsViewController: UISearchBarDelegate {
    
    // Search bar functionality
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText != "" {
            filteredRestaurants = restaurantsArray.filter { (r: Restaurant) -> Bool in
                return r.name.lowercased().contains(searchText.lowercased())
            }
        }
        else {
            filteredRestaurants = restaurantsArray
        }
        tableView.reloadData()
    }
    
    
    // Show Cancel button when typing
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    // Logic for searchBar cancel button
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false // remove cancel button
        searchBar.text = "" // reset search text
        searchBar.resignFirstResponder() // remove keyboard
        filteredRestaurants = restaurantsArray // reset results to display
        tableView.reloadData()
    }
    
}

extension RestaurantsViewController: SkeletonTableViewDataSource {
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "RestaurantCell"
    }
    
    func startAnimation() {
        animationView = .init(name: "4762-food-carousel")
        
        let length = 200
        animationView!.frame = CGRect(x: Int(view.frame.width)/2 - length/2, y: Int(view.frame.height)/2 - length/2, width: length, height: length)
        
        animationView!.contentMode = .scaleAspectFit
        view.addSubview(animationView!)
        
        animationView!.loopMode = .loop
        
        animationView!.animationSpeed = 5
        
        animationView!.play()
        view.showGradientSkeleton()
    }
    
    @objc func stopAnimation() {
        animationView!.stop()
        view.hideSkeleton()
        view.subviews.last?.removeFromSuperview()
        view.hideSkeleton()
        self.refresh = false
    }
}





