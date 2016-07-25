//
//  ViewController.swift
//  CameraApp
//
//  Created by momoko on 2016/07/23.
//  Copyright © 2016年 CameraApp. All rights reserved.
//
// エラー！An App ID with Identifier 'CameraApp.CameraApp' is not available. Please enter a different string.

import UIKit
import AVFoundation
import Social

class ViewController: UIViewController {
    
    // 撮影用のセッション
    var mySession : AVCaptureSession!
    
    // 撮影情報として必要なデバイス
    var myDevice : AVCaptureDevice!
    
    // 画像出力用の変数
    var myImageOutput : AVCaptureStillImageOutput!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // セッションの作成.
        mySession = AVCaptureSession()
        
        // デバイス一覧の取得.
        let devices = AVCaptureDevice.devices()
        
        // バックカメラをmyDeviceに格納.
        for device in devices{
            if(device.position == AVCaptureDevicePosition.Back){
                myDevice = device as! AVCaptureDevice
            }
        }
        
        // バックカメラからVideoInputを取得.
        let videoInput: AVCaptureInput!
        do {
            videoInput = try AVCaptureDeviceInput.init(device: myDevice!)
        }catch{
            videoInput = nil
        }
        
        // セッションに追加.
        mySession.addInput(videoInput)
        // 出力先を生成.
        myImageOutput = AVCaptureStillImageOutput()
        // セッションに追加.
        mySession.addOutput(myImageOutput)
        
        // 画像を表示するレイヤーを生成.
        let myVideoLayer : AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer.init(session:mySession)
        myVideoLayer.frame = self.view.bounds
        myVideoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        // Viewに追加.
        self.view.layer.addSublayer(myVideoLayer)
        
        // セッション開始.
        mySession.startRunning()
        
        // UIボタンを作成.
        let myButton = UIButton(frame: CGRectMake(0,0,120,50))
        myButton.backgroundColor = UIColor.blueColor()
        myButton.layer.masksToBounds = true
        myButton.setTitle("撮影&ポスト", forState: .Normal)
        myButton.layer.cornerRadius = 20.0
        myButton.layer.position = CGPoint(x: self.view.bounds.width/2, y:self.view.bounds.height-50)
        myButton.addTarget(self, action: "onClickMyButton:", forControlEvents: .TouchUpInside)
        
        // UIボタンをViewに追加.
        self.view.addSubview(myButton);
    }
    
    // ボタンイベント.
    func onClickMyButton(sender: UIButton){
        // ビデオ出力に接続.
        let myVideoConnection = myImageOutput.connectionWithMediaType(AVMediaTypeVideo)
        
        // 接続から画像を取得.
        self.myImageOutput.captureStillImageAsynchronouslyFromConnection(myVideoConnection, completionHandler: { (imageDataBuffer, error) -> Void in
            
            // 取得したImageのDataBufferをJpegに変換.
            let myImageData : NSData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataBuffer)
            
            // JpegからUIIMageを作成.
            let myImage : UIImage = UIImage(data: myImageData)!
            
            // アルバムに追加.
            UIImageWriteToSavedPhotosAlbum(myImage, self, nil, nil)
            
            // Facebook投稿画面を作成
            var myFComposeView : SLComposeViewController!
            
            myFComposeView = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            myFComposeView.setInitialText("カメラアプリ作ったよ :) #SweetSwift #AndCode #スウィスウィ")
            // 撮影した画像を貼り付け
            myFComposeView.addImage(myImage)
            self.presentViewController(myFComposeView, animated: true, completion: nil)
            
        })
        
        
    }
}
