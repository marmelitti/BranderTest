//
//  AddUserViewController.swift
//  BranderTest
//
//  Created by Alexandra Brovko on 01/08/2023.
//

import UIKit

class AddUserViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var users: [AppUser]? = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchDataFromAPI { result in
            switch result {
            case .success(let data):
                if let parsedUsers = self.parseRandomUsers(from: data) {
                    DispatchQueue.main.async {
                        self.users = parsedUsers
                        self.tableView.reloadData()
                    }
                } else {
                    // Handle parsing error
                }
            case .failure(let error):
                print("Error fetching data: \(error)")
            }
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: UserTableViewCell.reuseId, bundle: nil), forCellReuseIdentifier: UserTableViewCell.reuseId)
    }
    
    private func fetchDataFromAPI(completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: "https://randomuser.me/api/") else {
            completion(.failure(NSError(domain: "com.example", code: 0, userInfo: nil)))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "com.example", code: 0, userInfo: nil)))
                return
            }

            completion(.success(data))
        }

        task.resume()
    }
    
    private func parseRandomUsers(from data: Data) -> [AppUser]? {
        do {
            let decoder = JSONDecoder()
            let response = try decoder.decode(RandomUserResponse.self, from: data)
            return response.results
        } catch {
            print("Error: \(error)")
            return nil
        }
    }
    
}

extension AddUserViewController: UITableViewDelegate, UITableViewDataSource {
    
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let user = users?[indexPath.row] else { return }
        DatabaseManager.shared.saveUser(user: user)
        if let rootViewController = navigationController?.viewControllers.first {
            navigationController?.popToViewController(rootViewController, animated: true)
        }
    }
    
}

