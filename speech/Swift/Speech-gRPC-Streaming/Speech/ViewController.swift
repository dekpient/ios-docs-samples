//
// Copyright 2016 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
import UIKit
import AVFoundation

let SAMPLE_RATE = 16000

class ViewController : UIViewController, AudioControllerDelegate {
  @IBOutlet weak var textView: UITextView!
  var audioData: Data!

  override func viewDidLoad() {
    super.viewDidLoad()
    AudioController.sharedInstance.delegate = self
    AudioController.sharedInstance.requestRecordingPermission { [weak self] (givenAccess) in
      print("Requested permission \(givenAccess)")
    }
  }

  @IBAction func recordAudio(_ sender: NSObject) {
    let audioSession = AVAudioSession.sharedInstance()
    do {
      try audioSession.setCategory(AVAudioSession.Category.record)
    } catch {

    }
    audioData = Data()
    _ = AudioController.sharedInstance.prepare(specifiedSampleRate: SAMPLE_RATE)
    SpeechRecognitionService.sharedInstance.sampleRate = SAMPLE_RATE
    _ = AudioController.sharedInstance.start()
    
    // Long running / Recognize
//    AudioController.sharedInstance.startRecording()
  }

  @IBAction func stopAudio(_ sender: NSObject) {
    _ = AudioController.sharedInstance.stop()
    SpeechRecognitionService.sharedInstance.stopStreaming()
    
    // Long running / Recognise
//    AudioController.sharedInstance.finishRecording(success: true)
//    let data = try! Data(contentsOf: AudioController.sharedInstance.audioFileName)
    
//    print("------- Long Running Recognize --------")
//    SpeechRecognitionService.sharedInstance.longRunningRecognize(data)
    
//    print("-------Recognize --------")
//    SpeechRecognitionService.sharedInstance.recognize(data)
  }
  
  func didFinishRecording(withSuccess success: Bool) {
    print("Recording finished: \(success)")
  }

  func processSampleData(_ data: Data) -> Void {
    audioData.append(data)

    // We recommend sending samples in 100ms chunks
    let chunkSize : Int /* bytes/chunk */ = Int(0.1 /* seconds/chunk */
      * Double(SAMPLE_RATE) /* samples/second */
      * 2 /* bytes/sample */);

    if (audioData.count > chunkSize) {
      SpeechRecognitionService.sharedInstance.streamAudioData(audioData)
      self.audioData = Data()
    }
  }
}
