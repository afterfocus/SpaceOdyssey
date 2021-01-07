//
//  ViewController.swift
//  SpaceQuest
//
//  Created by Максим Голов on 16.11.2020.
//

import UIKit

// MARK: RouteListViewController

class RouteListViewController: UIViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var routesTableView: UITableView!
    
    // MARK: - Segue Properties
    
    let routes = DataProvider.routes
    
    // MARK: - Private Properties
    
    private var selectedIndexPath: IndexPath!
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()

        if let tabBarLayer = tabBarController?.tabBar.layer {
            tabBarLayer.masksToBounds = true
            tabBarLayer.cornerRadius = 20
            tabBarLayer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        
        routesTableView.backgroundView = UIImageView(withImageNamed: "background_main.png", alpha: 0.6)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        routesTableView.reloadData()
        routesTableView.selectRow(at: selectedIndexPath, animated: false, scrollPosition: .none)
    }
}


// MARK: - RouteTableViewCellDelegate

extension RouteListViewController: RouteTableViewCellDelegate {
    
    func routeTableViewCell(_ cell: RouteTableViewCell, didSelectRouteVariationAt index: Int) {
        guard let routeIndex = routesTableView.indexPath(for: cell)?.row,
              let questionsVC = storyboard?.instantiateViewController(withIdentifier: "QuestionListViewController") as? QuestionListViewController else { return }
        questionsVC.route = routes[routeIndex]
        questionsVC.routeVariation = routes[routeIndex].variations[index]
        navigationController?.pushViewController(questionsVC, animated: true)
    }
}


// MARK: - UITableViewDataSource

extension RouteListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: RouteTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.configure(with: routes[indexPath.row])
        cell.delegate = self
        return cell
    }
}


// MARK: - UITableViewDelegate

extension RouteListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        tableView.performBatchUpdates(nil)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath == tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
            selectedIndexPath = nil
            tableView.performBatchUpdates(nil)
            return nil
        }
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == selectedIndexPath {
            return CGFloat(220 + 61 * routes[indexPath.row].variations.count)
        } else {
            return 220
        }
    }
}

