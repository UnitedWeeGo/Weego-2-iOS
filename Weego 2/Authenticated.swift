import UIKit
import Firebase
import FirebaseDatabase
import FBSDKLoginKit
import RxSwift
import AsyncDisplayKit

class Authenticated: ASViewController<ASDisplayNode> {
  private let storage: Storage
  private let disposeBag: DisposeBag = DisposeBag()

  init(withStorage storage: Storage)
  {
    self.storage = storage

    let rootNode = ASDisplayNode()
    rootNode.backgroundColor = UIColor.white

    super.init(node: rootNode)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    storage.rxState.flatMapLatest { state  in
      return Observable.just(state.userState.authed)
      }
      .filter { !$0 }
      .distinctUntilChanged()
      .subscribe(onNext: { [weak self] authed in
        guard let weakSelf = self else { return }
        print("===== PFFFFFFF! User loged out!")
        weakSelf.presentingViewController?.dismiss(animated: true) {
          print("Authenticated VC dismissed")
        }
      })
      .addDisposableTo(disposeBag);

    let logoutBtn = UIButton(type: .system)
    logoutBtn.setTitle("Logout", for: .normal)
    logoutBtn.addTarget(self, action: #selector(doLogout), for: .touchDown)
    self.view.addSubview(logoutBtn)

    let margins = view.layoutMarginsGuide
    logoutBtn.translatesAutoresizingMaskIntoConstraints = false
    logoutBtn.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 16).isActive = true
    logoutBtn.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
    logoutBtn.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true

    let dynamicLinkBtn = UIButton(type: .system)
    dynamicLinkBtn.setTitle("Generate Dynamic Link Example", for: .normal)
    dynamicLinkBtn.addTarget(self, action: #selector(genDynamicLink), for: .touchDown)
    self.view.addSubview(dynamicLinkBtn)

    dynamicLinkBtn.translatesAutoresizingMaskIntoConstraints = false
    dynamicLinkBtn.topAnchor.constraint(equalTo: logoutBtn.bottomAnchor, constant: 16).isActive = true
    dynamicLinkBtn.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
    dynamicLinkBtn.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true

    let addEventBtn = UIButton(type: .system)
    addEventBtn.setTitle("Create A Random Event", for: .normal)
    addEventBtn.addTarget(self, action: #selector(createRandomEvent), for: .touchDown)
    self.view.addSubview(addEventBtn)

    addEventBtn.translatesAutoresizingMaskIntoConstraints = false
    addEventBtn.topAnchor.constraint(equalTo: dynamicLinkBtn.bottomAnchor, constant: 16).isActive = true
    addEventBtn.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
    addEventBtn.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true

    let updateEventBtn = UIButton(type: .system)
    updateEventBtn.setTitle("Update The Last Event", for: .normal)
    updateEventBtn.addTarget(self, action: #selector(updateSomeEvent), for: .touchDown)
    self.view.addSubview(updateEventBtn)

    updateEventBtn.translatesAutoresizingMaskIntoConstraints = false
    updateEventBtn.topAnchor.constraint(equalTo: addEventBtn.bottomAnchor, constant: 16).isActive = true
    updateEventBtn.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
    updateEventBtn.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true

  }

  func doLogout() {
    let firebaseAuth = Auth.auth()
    do {
      try firebaseAuth.signOut()
      Database.database().reference().removeAllObservers()
      FBSDKLoginManager.init().logOut()
      self.userDidLogOut()
    } catch let signOutError as NSError {
      print ("Error signing out: %@", signOutError)
    }
  }

  // Example: Generating a programmatic Dynamic Link
  func genDynamicLink() {
    let user = Auth.auth().currentUser
    guard let displayName = user?.displayName else {
      fatalError("displayName empty")
    }

    guard let escapedDisplayName = displayName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
      fatalError("displayName failed to escape")
    }

    let dynamicLinkDomain = "e398h.app.goo.gl"
    let deepLinkString = "https://weego.live/invite?displayName=\(escapedDisplayName)&eventId=someEventId"


    guard let deepLink = URL(string: deepLinkString) else {
      fatalError("deepLink failed to construct")
    }

    let components = DynamicLinkComponents(link: deepLink, domain: dynamicLinkDomain)

    let iOSParameters = DynamicLinkIOSParameters(bundleID: "unitedwego.Weego-2")
    iOSParameters.minimumAppVersion = "2.0.0"
    iOSParameters.appStoreID = "1243780258"

    components.iOSParameters = iOSParameters

    print("long url generated: \(String(describing: components.url))")

    let options = DynamicLinkComponentsOptions()
    options.pathLength = .short
    components.options = options

    components.shorten { (shortURL, warnings, error) in
      // Handle shortURL.
      if let error = error {
        print("url shortning error: \(error.localizedDescription)")
        return
      }
      print("url shortning success: \(String(describing: shortURL?.absoluteString))")
      // send over SMS dude!
    }
  }

  // Example: Add an event record to DB, trigger listening cloud function
  var lastEvent: WeegoEvent!
  var lastEventUID: String!
  func createRandomEvent() {
    let ref = Database.database().reference()
    lastEventUID = ref.child("events").childByAutoId().key

    guard let authorUID = Auth.auth().currentUser?.uid else { fatalError("user UID missing!") }
    let displayName = Auth.auth().currentUser?.displayName ?? ""
    let title = "Event title \(arc4random_uniform(5000))"
    lastEvent = WeegoEvent(authorUID: authorUID, authorDisplayName: displayName, title: title)

    // Duplication of event data is a Firebase Fan-out strategy
    let childUpdates = [
        "/events/\(lastEventUID!)/": lastEvent.toJSON(),
        "/user-events/\(authorUID)/\(lastEventUID!)/": lastEvent.toJSON(),
        "/participants/\(lastEventUID!)": [authorUID: true]
    ]
    ref.updateChildValues(childUpdates)

    // Create listeners for changes to data
    let eventRef = ref.child("user-events").child(authorUID).child(lastEventUID!)
    eventRef.observe(.value, with: { (snapshot) in
      let event = WeegoEvent(snapshot: snapshot)
      self.lastEvent = event
      print("Event \(String(describing: event?.title)) changed!")
      print("Creation date: \(String(describing: event?.created.formatted()))")
    })
  }

  func updateSomeEvent() {
    guard var event = lastEvent else {
      print("Create an event before attempting an update!")
      return
    }
    event.title = "Updated title \(arc4random_uniform(5000))"
    lastEvent = event
    let ref = Database.database().reference()
    let childUpdates = [
        "/user-events/\(event.authorUID)/\(lastEventUID!)/": lastEvent.toJSON(),
        "/events/\(lastEventUID!)/": lastEvent.toJSON()
    ]
    ref.updateChildValues(childUpdates)
  }

  private func userDidLogOut()
  {
    let action = UserDidLogOutAction()
    storage.dispatch(action)
  }

}
