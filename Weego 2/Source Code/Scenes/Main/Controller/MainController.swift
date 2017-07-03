import AsyncDisplayKit
import Firebase

class MainController: BaseController {
  private let rootNode = ASDisplayNode ()
  private let storage: Storage

  init(withStorage storage: Storage) {
    self.storage = storage
    super.init(node: rootNode)

    do {
      try Auth.auth().signOut()
    } catch let signOutError as NSError {
      print ("Error signing out: %@", signOutError)
    }

    // Monitors login/out for cloud func logging of info
    _ = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
      guard let weakSelf = self else { return }
      guard let authedUser = user else {
        weakSelf.presentAuthScreen()
        return
      }

      print(auth);
      print(authedUser);

      print("User photo URL: \(authedUser.providerData[0].photoURL?.absoluteString ?? "")")

      let userRef = Database.database().reference().child("queues/login").child(authedUser.uid)
      userRef.removeValue(completionBlock: { (error, ref) in

        let loginRecord = [
          "displayName": authedUser.providerData[0].displayName ?? "",
          "photoURL": authedUser.providerData[0].photoURL?.absoluteString ?? "",
          "fbUID": authedUser.providerData[0].uid
          ] as [String : Any]

        ref.setValue(loginRecord)
      })

    }
  }

  private func presentApplication()
  {
    print("🚨 Present Application")
  }

  private func presentAuthScreen()
  {
    let authViewModel = AuthViewModel(withStorage: storage)
    let controller  = AuthController(withStorage: storage, withViewModel: authViewModel)
    self.navigationController?.present(controller, animated: false, completion: { 
      print("❗️ MainController did present AuthController")
    });
  }

}
