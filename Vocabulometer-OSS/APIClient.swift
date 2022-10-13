//
//  APIClient.swift
//  Vocabulometer-OSS
//
//  Created by iwashita on 2022/10/13.
//

import Foundation

public enum APIClientError: Error {
    case invalidURL
    case responseError
    case parseError(Error)
    case serverError(Error)
    case badStatus(statusCode: Int)
    case noData
}
