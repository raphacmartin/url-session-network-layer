//
//  HomeViewController.swift
//  URLSessionNetworkLayer
//
//  Created by Raphael Martin on 25/03/25.
//

import UIKit

class HomeViewController: UIViewController {

    var userRequestTask: URLSessionTask? = nil
    
    func getUser() {
        let apiClient = DummyJSONAPIClient()
        let userService = UserService(apiClient: apiClient)
        
        userRequestTask = userService.currentUser { [weak self] result in
            // ...
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Cancelling a possible request since the user is leaving the page
        userRequestTask?.cancel()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
