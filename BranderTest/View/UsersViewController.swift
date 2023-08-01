//
//  UsersViewController.swift
//  BranderTest
//
//  Created by Alexandra Brovko on 01/08/2023.
//

import UIKit
import CoreData

class UsersViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var users: [AppUser]? = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: UserTableViewCell.reuseId, bundle: nil), forCellReuseIdentifier: UserTableViewCell.reuseId)
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        users = DatabaseManager.shared.fetchAllUsers()

        tableView.reloadData()
    }
    
    private func setupNavigationBar() {
        let addButton = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addTapped))
        navigationItem.rightBarButtonItem = addButton
        navigationItem.title = "Friends list"
    }
    
    @objc func addTapped() {
        let nextViewController = AddUserViewController()
        navigationController?.pushViewController(nextViewController, animated: true)
    }

}

extension UsersViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserTableViewCell.reuseId, for: indexPath) as! UserTableViewCell
        guard let user = users?[indexPath.row] else { return UITableViewCell() }
        
        cell.nameLabel.text = "\(user.name.first) \(user.name.last)"
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: URL(string: user.picture.thumbnail)!){
                if let image = UIImage(data:data){
                    DispatchQueue.main.async{
                        cell.usersImageView.image = image
                    }
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let userToDelete = users?[indexPath.row]
            
            let context = DatabaseManager.shared.persistentContainer.viewContext
            
            let fetchRequest: NSFetchRequest<CDUser> = CDUser.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "email == %@", (userToDelete?.email)!)
            
            do {
                let matchingUsers = try context.fetch(fetchRequest)
                if let userToDelete = matchingUsers.first {
                    context.delete(userToDelete)
                    do {
                        try context.save()
                    } catch {
                        print("Error saving context: \(error)")
                    }
                    users?.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
            } catch {
                print("Error fetching user to delete: \(error)")
            }
        }
    }
    
}
