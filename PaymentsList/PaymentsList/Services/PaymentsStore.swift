//
//  PaymentsStore.swift
//  PaymentsList
//
//  Created by Oleg Bondar on 21.10.2021.
//

import Foundation
import Combine

public class PaymentsStore {
    
    public static let shared = PaymentsStore()
    private init() {}
    private let appKey = "12345" //"APP_KEY"
    private let v = "1" //"V"
    private let baseAPI_URL = "http://82.202.204.94/api-test/"
    private let urlSession = URLSession.shared
    
    private let jsonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-mm-dd"
        jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
        return jsonDecoder
    }()
    
    private var subscriptions = Set<AnyCancellable>()

    private func generateURL(subpath: String, queryItems: [URLQueryItem]) -> URL? {
        guard var urlComponents = URLComponents(string: baseAPI_URL + subpath) else {
            return nil
        }
        
        urlComponents.queryItems = queryItems
        return urlComponents.url
    }

    func fetchPayments(token: String) -> Future<[Payment], StoreAPIError> {
        return Future<[Payment], StoreAPIError> {[unowned self] promise in
            let queryItems = [URLQueryItem(name: "token", value: token)]
            guard let url = self.generateURL(subpath: "payments", queryItems: queryItems) else {
                return promise(.failure(.urlError(URLError(URLError.unsupportedURL))))
            }

            var request = URLRequest(url: url)
            request.addValue(appKey, forHTTPHeaderField: "app-key")
            request.addValue(v, forHTTPHeaderField: "v")
            request.httpMethod = "GET"
            dump(request)
            self.urlSession.dataTaskPublisher(for: request)
                .tryMap { (data, response) -> Data in
                    guard let httpResponse = response as? HTTPURLResponse,
                          200...299 ~= httpResponse.statusCode else {
                        throw StoreAPIError.responseError(
                            (response as? HTTPURLResponse)?.statusCode ?? 500)
                    }
//                    let t = String(data: data, encoding: String.Encoding.ascii)
//                    print(t)
//                    let decoder = JSONDecoder()
//                    let loginResult = try! decoder.decode(PaymentsResponse.self, from: data)
//                    dump(loginResult)
//                    dump(data)
                    return data
            }
            .decode(type: PaymentsResponse.self, decoder: self.jsonDecoder)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    switch error {
                    case let urlError as URLError:
                        promise(.failure(.urlError(urlError)))
                    case let decodingError as DecodingError:
                        promise(.failure(.decodingError(decodingError)))
                    case let apiError as StoreAPIError:
                        promise(.failure(apiError))
                    default:
                        promise(.failure(.genericError))
                    }
                }
            }, receiveValue: {
                promise(.success($0.response))
                dump($0.response)
            })
            .store(in: &self.subscriptions)
        }
    }

    func loginRequest(username: String, password: String) -> URLRequest? {
        guard let url = self.generateURL(subpath: "login", queryItems: []) else {
            return nil
        }
        
        let b = "login=" + username + "&password=" + password
        let postData = b.data(using: String.Encoding.ascii) //Data(base64Encoded: b)
        var request = URLRequest(url: url)
        request.httpBody = postData
        request.addValue("12345", forHTTPHeaderField: "app-key")
        request.addValue("1", forHTTPHeaderField: "v")
        request.httpMethod = "POST"
        dump(request)
        return request
    }

    func login(username: String, password: String) -> Future<String, StoreAPIError> {
        return Future<String, StoreAPIError> {[unowned self] promise in
            guard let request = self.loginRequest(username: username, password: password) else {
                return promise(.failure(.urlError(URLError(URLError.unsupportedURL))))
            }
            
            self.urlSession.dataTaskPublisher(for: request)
                .tryMap { (data, response) -> Data in
                    guard let httpResponse = response as? HTTPURLResponse,
                          200...299 ~= httpResponse.statusCode else {
                        throw StoreAPIError.responseError(
                            (response as? HTTPURLResponse)?.statusCode ?? 500)
                    }
                    return data
            }
            .decode(type: LoginResult.self, decoder: self.jsonDecoder)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    switch error {
                    case let urlError as URLError:
                        promise(.failure(.urlError(urlError)))
                    case let decodingError as DecodingError:
                        promise(.failure(.decodingError(decodingError)))
                    case let apiError as StoreAPIError:
                        promise(.failure(apiError))
                    default:
                        promise(.failure(.genericError))
                    }
                }
            }, receiveValue: {
                let token = $0.response.token
                promise(.success(token))
                dump($0.response)
            })
            .store(in: &self.subscriptions)
        }
    }
}
