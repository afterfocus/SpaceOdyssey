//
//  OurHeroesController.swift
//  SpaceQuest
//
//  Created by Максим Голов on 14.02.2021.
//

import UIKit

// MARK: OurHeroesController

class OurHeroesController: UIViewController {
    
    // MARK: Private Properties
    
    private var heroes: [Author]!
    private var heroPhotos: [UIImage?]!
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let sortedHeroes = Array(DataModel.authors.values).sorted { $0.surname < $1.surname }
        heroes = DataModel.vipAuthors + sortedHeroes
        heroPhotos = Array(repeating: nil, count: heroes.count)
    }
}


// MARK: - UITableViewDataSource

extension OurHeroesController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return heroes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: OurHeroesTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        let row = indexPath.row
        let hero = heroes[row]
        
        if heroPhotos[row] == nil {
            heroPhotos[row] = UIImage(named: hero.photoFilename)
        }
        cell.fioLabel.text = hero.fio
        cell.aboutAuthorLabel.text = hero.aboutAuthorFull
        cell.photoImageView.image = heroPhotos[row]
        return cell
    }
}
