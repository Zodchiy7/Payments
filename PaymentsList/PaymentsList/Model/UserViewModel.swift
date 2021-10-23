//
//  UserViewModel.swift
//  PaymentsList
//
//  Created by Oleg Bondar on 21.10.2021.
//

import Foundation
import Combine

final class UserViewModel: ObservableObject {
    var paymentAPI = PaymentsStore.shared

    // input
    @Published var username = ""
    @Published var password = ""
    @Published var token: String?

    // output
    @Published var isValid = false
    @Published var payments = [Payment]()
    @Published var paymentsError: StoreAPIError?

    private var cancellableSet: Set<AnyCancellable> = []

    private var isUsernameValidPublisher: AnyPublisher<Bool, Never> {
      $username
        .debounce(for: 0.8, scheduler: RunLoop.main)
        .removeDuplicates()
        .map { input in
            return input.count > 0
        }
        .eraseToAnyPublisher()
    }
    
    private var isPasswordValidPublisher: AnyPublisher<Bool, Never> {
      $password
        .debounce(for: 0.8, scheduler: RunLoop.main)
        .removeDuplicates()
        .map { password in
            return password.count > 0
        }
        .eraseToAnyPublisher()
    }
    
    private var isFormValidPublisher: AnyPublisher<Bool, Never> {
      Publishers.CombineLatest(isUsernameValidPublisher, isPasswordValidPublisher)
        .map { userNameIsValid, passwordIsValid in
          return userNameIsValid && passwordIsValid
        }
      .eraseToAnyPublisher()
    }
    
    init() {
        isFormValidPublisher
          .receive(on: RunLoop.main)
          .assign(to: \.isValid, on: self)
          .store(in: &cancellableSet)
    }
    
    public func fetchPayments() {
        $token
            .setFailureType(to: StoreAPIError.self)
            .flatMap { (token) -> AnyPublisher<[Payment], StoreAPIError> in
                self.paymentAPI.fetchPayments(token: token ?? "")
                    .eraseToAnyPublisher()
            }
            .sink(receiveCompletion: {[unowned self](completion) in
                if case let .failure(error) = completion {
                    self.paymentsError = error
                }
            }, receiveValue: {[unowned self] in
                self.payments = $0
            })
            .store(in: &self.cancellableSet)
    }

    func login(showList: ()) {
        guard let request = paymentAPI.loginRequest(username: self.username, password: self.password) else {
            return
        }
        
        DispatchQueue.main.async {
            let dataTask = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
                //handle response here
                guard let httpResponse = response as? HTTPURLResponse,
                      200...299 ~= httpResponse.statusCode else {
                    print(StoreAPIError.responseError((response as? HTTPURLResponse)?.statusCode ?? 500))
                    return
                }
                if self.token == nil {
                    dump(data)
                    guard let d = data else { return }
                    let decoder = JSONDecoder()
                    let loginResult = try! decoder.decode(LoginResult.self, from: d)
                    let t = loginResult.response.token
                    self.token = t
                    self.fetchPayments()
                }
                showList
            }
            dataTask.resume()
        }
    }
}

struct LoginResult: Codable {
    let success: String
    let response: Res
    struct Res: Codable {
        let token: String
    }
}
