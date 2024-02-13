//
//  HomeScreen.swift
//  PoseEstimation
//
//  Created by Sanket Lothe on 05/02/24.
//  Copyright © 2024 tensorflow. All rights reserved.
//

import UIKit
import AVFoundation
import WebRTC
let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
class HomeScreenViewController: UIViewController {

    
    static var sharedInstance: HomeScreenViewController?
    private let config = Config.default
    private var signalClient: SignalingClient!
    private var webRTCClient: WebRTCClient!
    var remoteCandidateCount: Int = 0
    var localCandidateCount: Int = 0
    var expectedFileSize: Int?
    var receivedData = Data()
    var hasLocalSdp: Bool = false
    @IBOutlet weak var showMePopUp: UIButton!
    private var signalingConnected: Bool = false {
        didSet {
            DispatchQueue.main.async {
                if self.signalingConnected {
                   
                }
                else {
                   
                }
            }
        }
    }
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let signalClient = self.buildSignalingClient()
        let webRTCClient = WebRTCClient(iceServers: self.config.webRTCIceServers)
        self.signalClient = signalClient
        self.webRTCClient = webRTCClient
        self.signalingConnected = false
        
        self.webRTCClient.delegate = self
        self.signalClient.delegate = self
        self.signalClient.connect()
        HomeScreenViewController.sharedInstance = self
        // Do any additional setup after loading the view.
    }
    
    @IBAction func SendOffer(_ sender: Any) {
        SendOffer()

    }
    
    @IBAction func SendAnswer(_ sender: Any) {
        sendAnswer()

    }
    
    @IBAction func SendData(_ sender: Any) {
        sendData()

    }
    
    @IBAction func optionsBtn(_ sender: Any) {
        
        let helpView = PopUPView()
        view.addSubview(helpView)
        helpView.alpha = 0
        helpView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            helpView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            helpView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            helpView.topAnchor.constraint(equalTo: view.topAnchor),
            helpView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        UIView.animate(withDuration: 0.2) {
            helpView.alpha = 1.0
        }
        
    }
    
    private func buildSignalingClient() -> SignalingClient {
        
        // iOS 13 has native websocket support. For iOS 12 or lower we will use 3rd party library.
        let webSocketProvider: WebSocketProvider
        
        if #available(iOS 13.0, *) {
            webSocketProvider = NativeWebSocket(url: self.config.signalingServerUrl)
        } else {
            webSocketProvider = StarscreamWebSocket(url: self.config.signalingServerUrl)
        }
        
        return SignalingClient(webSocket: webSocketProvider)
    }
    func sendData()
    {
        if let url = Bundle.main.url(forResource: "textdatafile" , withExtension: "txt"){
            do {
                
                let audioData = try convertAudioFileToData(filePath: url.path)
                self.webRTCClient.sendFile(audioData , fileSize: audioData.count)
                  
                    
                print("Successfully loaded audio data. Size: \(audioData.count) bytes")
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }

    }
    func sendAnswer(){
        self.webRTCClient.answer { (localSdp) in
            self.hasLocalSdp = true
            self.signalClient.send(sdp: localSdp)
        }
    }
    func SendOffer(){
        self.webRTCClient.offer { (sdp) in
            self.hasLocalSdp = true
            
            self.signalClient.send(sdp: sdp)
        }
    }
//    @IBAction func showMeActionPop(_ sender: Any) {
//        
//        let alertController = UIAlertController(
//                                    title: "Choose Camera",
//                                    message: "Use Front Camera if you using the app alone",
//                                    preferredStyle: .alert)
//
//            // Handling OK action
//            let okAction = UIAlertAction(title: "Front", style: .default) { (action:UIAlertAction!) in
//                
//                let childVC =  TexturedFace.loadViewController(withStoryBoard: "Main")
//                self.navigationController?.pushViewController(childVC, animated: true)
//                          
//            }
//
//            // Handling Cancel action
//            let cancelAction = UIAlertAction(title: "Back", style: .default) { (action:UIAlertAction!) in
//                let childVC =  ARCameraBack.loadViewController(withStoryBoard: "Main")
//                self.navigationController?.pushViewController(childVC, animated: true)
//                          
//            }
//
//            // Adding action buttons to the alert controller
//            alertController.addAction(okAction)
//            alertController.addAction(cancelAction)
//
//            // Presenting alert controller
//            self.present(alertController, animated: true, completion:nil)
//    }
    
    
    func goToShowMe() {
//        let vc = TexturedFace.loadViewController(withStoryBoard: "Main")
//        navigationController?.navigationBar.isHidden = false
//        navigationController?.pushViewController(vc, animated: true)
//
       
        
        
        let alertController = UIAlertController(
                                    title: "Choose Camera",
                                    message: "Use Front Camera if you using the app alone",
                                    preferredStyle: .alert)

            // Handling OK action
            let okAction = UIAlertAction(title: "Front", style: .default) { (action:UIAlertAction!) in
                
                let childVC =  TexturedFace.loadViewController(withStoryBoard: "Main")
                self.navigationController?.pushViewController(childVC, animated: true)
                
            }

            // Handling Cancel action
            let cancelAction = UIAlertAction(title: "Back", style: .default) { (action:UIAlertAction!) in
                DispatchQueue.main.async {
                    if let presenter = self.navigationController?.presentedViewController {
                        presenter.dismiss(animated: true)
                                        print("isPresented")
                  
                                    }
//                    self.showLoader()
                }
                let childVC =  ARCameraBack.loadViewController(withStoryBoard: "Main")
                self.navigationController?.pushViewController(childVC, animated: true)
               
            }

            // Adding action buttons to the alert controller
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)

            // Presenting alert controller
            self.present(alertController, animated: true, completion:nil)

    }
    
    func removeARHelp() {
        for v in view.subviews {
            if v is PopUPView {
                UIView.animate(withDuration: 0.2, animations: {
                    v.alpha = 0
                }) { _ in

                    v.removeFromSuperview()
                }
            }
        }
    }
    

}
extension HomeScreenViewController: SignalClientDelegate {
    
    func signalClientDidConnect(_ signalClientDidConnect: SignalingClient) {
        print("signalClientDidConnect")

        self.signalingConnected = true

    }
    
    func signalClientDidDisconnect(_ signalClient: SignalingClient) {
        self.signalingConnected = false
    }
    
    func signalClient(_ signalClient: SignalingClient, didReceiveRemoteSdp sdp: RTCSessionDescription) {
        print("Received remote sdp")
        self.webRTCClient.set(remoteSdp: sdp) { (error) in
        }
    }
    
    func signalClient(_ signalClient: SignalingClient, didReceiveCandidate candidate: RTCIceCandidate) {
        self.webRTCClient.set(remoteCandidate: candidate) { error in
            print("Received remote candidate")
            
            self.remoteCandidateCount += 1
        }
    }
}
extension HomeScreenViewController: WebRTCClientDelegate {
    
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate) {
        print("discovered local candidate")
        self.localCandidateCount += 1
        self.signalClient.send(candidate: candidate)
    }
    
    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState) {
        let textColor: UIColor
        switch state {
        case .connected, .completed:
            textColor = .green
        case .disconnected:
            textColor = .orange
        case .failed, .closed:
            textColor = .red
        case .new, .checking, .count:
            textColor = .black
        @unknown default:
            textColor = .black
        }
      
    }
    
    func webRTCClient(_ client: WebRTCClient, didReceiveData data: Data) {
            do{
                  let packet = try PropertyListDecoder.init().decode(Packet.self, from: data)
                print(packet,"data packet")
                  if self.expectedFileSize == nil {
                      self.expectedFileSize = packet.fileSize
                   }
                if let decodedData = Data(base64Encoded: packet.fileData, options: .ignoreUnknownCharacters){
                    self.receivedData.append(decodedData)
                }
               
            
            if self.receivedData.count == self.expectedFileSize {
                self.saveFile()
                print("dataRecive",data.count)
                DispatchQueue.main.async {
                    DispatchQueue.main.async {
                               let message =  "(Audio File Recived)"
                               let alert = UIAlertController(title: "Message from WebRTC", message: message, preferredStyle: .alert)
                               alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                               self.present(alert, animated: true, completion: nil)
                           }
                }
            }
           
                }catch let error as NSError{
                  print("Error:",error.localizedDescription)
                }
        
    }
    
    private func saveFile() {
           guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
               print("Error getting documents directory.")
               return
           }

           let fileURL = documentsDirectory.appendingPathComponent("receivedFile.wav")

           do {
               try receivedData.write(to: fileURL)
               print("File saved at: \(fileURL.absoluteString)")
           } catch {
               print("Error saving file: \(error)")
           }

           // Reset the state for potential future file receptions
           receivedData = Data()
           expectedFileSize = nil
       }
    
    
    func convertAudioFileToData(filePath: String) throws -> Data {
        do {

            let audioData = try Data(contentsOf: URL(fileURLWithPath: filePath))
            print("audioData is",audioData)
            return audioData
        } catch {
            throw error
        }
    }
    
}

