//
//  VoiceCore.swift
//  NotesForTheVisuallyChallenged
//
//  Created by Yen-Kuei Huang on 23/05/2017.
//  Copyright © 2017 MAP. All rights reserved.
//\
import Speech
import AVFoundation
import UIKit

class VoiceButton:UIButton {
    
    //for speech api
    let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "zh"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    //for AVFoundation
    let synth = AVSpeechSynthesizer()
    var myUtterance = AVSpeechUtterance(string: "")
   
    var recogResult : String?
   
    func startRecording(){
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode else {
            fatalError("Audio engine has no input node")
        }
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil {
                
                self.recogResult = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
       
        
        print(self.recogResult ?? "no recogResult")
    }
    
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            self.isEnabled = true
        } else {
            self.isEnabled = false
        }
    }
    

    
    
    func load() {
//        self.isEnabled = false  //2
//        speechRecognizer?.delegate = self  //3
//        
//        SFSpeechRecognizer.requestAuthorization { (authStatus) in  //4
//            
//            var isButtonEnabled = false
//            
//            switch authStatus {  //5
//            case .authorized:
//                isButtonEnabled = true
//                
//            case .denied:
//                isButtonEnabled = false
//                print("User denied access to speech recognition")
//                
//            case .restricted:
//                isButtonEnabled = false
//                print("Speech recognition restricted on this device")
//                
//            case .notDetermined:
//                isButtonEnabled = false
//                print("Speech recognition not yet authorized")
//            }
//            
//            OperationQueue.main.addOperation() {
//                self.isEnabled = isButtonEnabled
//            }
//        }
    }
    
    func mainMenu(){
        guard !self.synth.isSpeaking else {
            self.synth.stopSpeaking(at: AVSpeechBoundary.word)
            return
        }
        self.speak("您好，請念數字來選擇功能",rate: 0.55)
        self.speak("ㄧ、新增筆記", rate:0.5)
        self.speak("二、列出、選擇筆記", rate:0.5)
        self.recogTapped()
        
    }
    
    func recogTapped() {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            self.isEnabled = false
              print("Start Recording")
        } else {
            self.startRecording()
           print("Stop Recording")
        }
    }
    func speak(_ sender: String,rate r : Float) {
        myUtterance = AVSpeechUtterance(string: sender)
        myUtterance.voice =  AVSpeechSynthesisVoice(language: "zh")
        myUtterance.rate = r
        myUtterance.volume = 70.0
        synth.speak(myUtterance)
    }
    
}

