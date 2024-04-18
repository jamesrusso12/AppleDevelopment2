import UIKit
import SceneKit
import ARKit
import AVKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var videoPlayer: AVPlayer?
    var videoPlayer2: AVPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        
        // Add tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        sceneView.addGestureRecognizer(tapGesture)
        
        //Load the video
        guard let url = Bundle.main.url(forResource: "MarshallMcluhanSpeaks", withExtension: "mp4") else {
            fatalError("Video not found")
        }
        videoPlayer = AVPlayer(url: url)
        
        // Load the second video
        guard let url2 = Bundle.main.url(forResource: "DemoReleaseApp", withExtension: "mp4") else {
            fatalError("Second Video not found")
        }
        videoPlayer2 = AVPlayer(url: url2)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: Bundle.main) else {
            fatalError("No Image load")
        }
        configuration.trackingImages = referenceImages

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        videoPlayer?.pause()
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor){
        if let imageAnchor = anchor as? ARImageAnchor {
            let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)

            if imageAnchor.referenceImage.name == "McLuhanbook" {
                // Use the first video player for the first marker
                plane.firstMaterial?.diffuse.contents = videoPlayer
            } else if imageAnchor.referenceImage.name == "Johnson" {
                // Use the second video player for the second marker
                plane.firstMaterial?.diffuse.contents = videoPlayer2
            }

            let planeNode = SCNNode(geometry: plane)
            planeNode.eulerAngles.x = -.pi / 2
            node.addChildNode(planeNode)
            
            // Start playing the corresponding video player
            if imageAnchor.referenceImage.name == "MarshallMcluhanSpeaks" {
                videoPlayer?.play()
            } else if imageAnchor.referenceImage.name == "DemoReleaseName" {
                videoPlayer2?.play()
            }
        }
    }

    
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
            if let player1 = videoPlayer, let player2 = videoPlayer2 {
                if player1.rate == 0 {
                    player1.play()
                } else {
                    player1.pause()
                }
                
                if player2.rate == 0 {
                    player2.play()
                } else {
                    player2.pause()
                }
            }
        }
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
