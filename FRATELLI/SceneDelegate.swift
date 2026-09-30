//
//  SceneDelegate.swift
//  FRATELLI
//
//  Created by Sakshi on 18/10/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var navigationController : UINavigationController?
    private(set) static var shared: SceneDelegate?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if Defaults.isUserLoggedIn ?? false && Defaults.isSyncUpProcessCompleted ?? false {
            gotoTabbar()
        } else if Defaults.isUserLoggedIn ?? false && !(Defaults.isSyncUpProcessCompleted ?? true)  {
            gotoSyncView()
        } else {
            gotoLoginView()
        }
        guard let _ = (scene as? UIWindowScene) else { return }
    }
    
    
    
    static func getSceneDelegate() -> SceneDelegate {
        return UIApplication.shared.connectedScenes.first?.delegate as! SceneDelegate
    }
    
    func gotoTabbar() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Tabbar", bundle:nil)
        let tabbarView = storyBoard.instantiateViewController(withIdentifier: "TabbarView") as? TabbarView
        SceneDelegate.getSceneDelegate().navigationController = UINavigationController(rootViewController: tabbarView ?? TabbarView())
        SceneDelegate.getSceneDelegate().navigationController?.isNavigationBarHidden = true
        SceneDelegate.getSceneDelegate().window!.rootViewController = SceneDelegate.getSceneDelegate().navigationController
        
//        let storyBoard : UIStoryboard = UIStoryboard(name: "Home", bundle:nil)
//        let tabbarView = storyBoard.instantiateViewController(withIdentifier: "VisibilityVC") as? VisibilityVC
//        SceneDelegate.getSceneDelegate().navigationController = UINavigationController(rootViewController: tabbarView ?? VisibilityVC())
//        SceneDelegate.getSceneDelegate().navigationController?.isNavigationBarHidden = true
//        SceneDelegate.getSceneDelegate().window!.rootViewController = SceneDelegate.getSceneDelegate().navigationController
    }
    
    func gotoLoginView() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let viewController = storyBoard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        SceneDelegate.getSceneDelegate().navigationController = UINavigationController(rootViewController: viewController)
        SceneDelegate.getSceneDelegate().navigationController?.isNavigationBarHidden = true
        SceneDelegate.getSceneDelegate().window!.rootViewController = SceneDelegate.getSceneDelegate().navigationController
    }
    
    func gotoSyncView() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let viewController = storyBoard.instantiateViewController(withIdentifier: "SyncVC") as! SyncVC
        SceneDelegate.getSceneDelegate().navigationController = UINavigationController(rootViewController: viewController)
        SceneDelegate.getSceneDelegate().navigationController?.isNavigationBarHidden = true
        SceneDelegate.getSceneDelegate().window!.rootViewController = SceneDelegate.getSceneDelegate().navigationController
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

