//
//  AppDelegate.swift
//  NASA_APOD_VIEWER_UIKIT
//
//  Created by Moorthy, Prashanth on 15/10/21.
//

import UIKit
import nasa_apod_dataservice

// swiftlint:disable line_length
@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var postViewModel: PostViewModel!
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Initialize PostViewModel.
        Task {
            postViewModel = await PostViewModel()
            
            let imageDisplayVC = UIApplication.shared.windows.first!.rootViewController as! NASAApodImageViewController
            //imageDisplayVC.configure(postTitleViewModel: postViewModel.postTitleViewModel.value)
            imageDisplayVC.postViewModel = postViewModel
            print(imageDisplayVC)
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

}
