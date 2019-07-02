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
import Foundation
import SwiftGRPC

let API_KEY : String = "YOUR_API_KEY"
let HOST = "speech.googleapis.com"

typealias SpeechRecognitionCompletionHandler = () -> (Void)

class SpeechRecognitionService {
  var sampleRate: Int = 16000
  private var streaming = false

  private var client : Google_Cloud_Speech_V1p1beta1_SpeechServiceClient!
  private var call : Google_Cloud_Speech_V1p1beta1_SpeechStreamingRecognizeCall!

  static let sharedInstance = SpeechRecognitionService()

  func streamAudioData(_ audioData: NSData) {
    if (!streaming) {
      // if we aren't already streaming, set up a gRPC connection
      client = Google_Cloud_Speech_V1p1beta1_SpeechServiceClient(address: HOST, secure: true)
      client.metadata = try! Metadata([
        "x-goog-api-key": API_KEY,
        "x-ios-bundle-identifier": Bundle.main.bundleIdentifier ?? "" // com.google.speech-grpc-streaming
        ])
      call = try! client.streamingRecognize { (result) in
        print("Result code: \(result.statusCode)")
        print("Result description: \(result.description)")
        print("Metadata: \(String(describing: result.initialMetadata))")
        print("Status message: \(result.statusMessage ?? "Error")")
        print("Obj description: \(String(describing: result))")
        print("=============================")
        self.streaming = false
      }

      streaming = true
      // send an initial request message to configure the service
      var recognitionConfig = Google_Cloud_Speech_V1p1beta1_RecognitionConfig()
      recognitionConfig.encoding = .linear16
      recognitionConfig.sampleRateHertz = Int32(sampleRate)
      recognitionConfig.languageCode = "en-US"
      recognitionConfig.maxAlternatives = 30
      recognitionConfig.enableWordTimeOffsets = true

      var streamingRecognitionConfig = Google_Cloud_Speech_V1p1beta1_StreamingRecognitionConfig()
      streamingRecognitionConfig.config = recognitionConfig
      streamingRecognitionConfig.singleUtterance = false
      streamingRecognitionConfig.interimResults = true

      var streamingRecognizeRequest = Google_Cloud_Speech_V1p1beta1_StreamingRecognizeRequest()
      streamingRecognizeRequest.streamingConfig = streamingRecognitionConfig

      try! call.send(streamingRecognizeRequest)
      print("Streaming")
    }

    // send a request message containing the audio data
    var streamingRecognizeRequest = Google_Cloud_Speech_V1p1beta1_StreamingRecognizeRequest()
    streamingRecognizeRequest.audioContent = audioData as Data
    do {
      try call.send(streamingRecognizeRequest)
    } catch {
      print(error.localizedDescription)
    }
  }

  func stopStreaming() {
    if (!streaming) {
      return
    }
    print("Stopped")
    streaming = false
  }

  func isStreaming() -> Bool {
    return streaming
  }

}

