//
//  UserModel.swift
//  BranderTest
//
//  Created by Alexandra Brovko on 01/08/2023.
//

import Foundation
import CoreData

struct RandomUserResponse: Codable {
    let results: [AppUser]
}

struct AppUser: Codable {
    let name: Name
    let email: String
    let dob: Dob
    let picture: UserPicture
}

struct Name: Codable {
    let title: String
    let first: String
    let last: String
}

struct Dob: Codable {
    let date: String
}

struct UserPicture: Codable {
    let large: String
    let medium: String
    let thumbnail: String
}
