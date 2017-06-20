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

protocol VoiceCoreDelegate {
    func messageData(data: AnyObject)
}

class VoiceCore:NSObject,AVSpeechSynthesizerDelegate,SFSpeechRecognizerDelegate {
    
    //for speech api
    let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "zh"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    let audioSession = AVAudioSession.sharedInstance()
    //for AVFoundation
    let synth = AVSpeechSynthesizer()
    var audioPlayer:AVAudioPlayer? // to play ding sound
    //    var queue = DispatchQueue(label: "audio")
    var semaphore = DispatchSemaphore(value: 1)
    
    var inMode1 = false
    var recogResult : String?
    let queue = DispatchQueue.global(qos: .userInitiated)
    var myUtterance = AVSpeechUtterance(string:"")
    
    override init(){
        super.init()
        synth.delegate = self
//        SFSpeechRecognitionTask.delegate = self
        
        //for speech api
        //   voiceBtn.isEnabled = false  //2
        speechRecognizer?.delegate = self  //3
        SFSpeechRecognizer.requestAuthorization { (authStatus) in  //4
            
            //            var isButtonEnabled = false
            
            switch authStatus {  //5
            case .authorized:
                print("authorized")
                //                isButtonEnabled = true
                
            case .denied:
                //                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                //                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                //                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            
            //            OperationQueue.main.addOperation() {
            //                self.isEnabled = isButtonEnabled
            //            }
        }
    }
    
    func audioSet (_ mode : String) ->Bool {
        print(audioSession.category)
        do{
            if mode == "play"{
                if audioSession.category != "AVAudioSessionCategoryAmbient"{
                    try audioSession.setCategory(AVAudioSessionCategoryAmbient)
                    try audioSession.setMode(AVAudioSessionModeMeasurement)
                    try audioSession.setActive(true)
                    print("set play")
                }
            }
            else if mode == "record"{
                if audioSession.category != ""{
                    try audioSession.setCategory(AVAudioSessionCategoryRecord)
                    try audioSession.setMode(AVAudioSessionModeMeasurement)
                    //                try audioSession.setActive(true,with: .notifyOthersOnDeactivation)
                    try audioSession.setActive(true)
                    print("set record")
                }
            }
            else if mode == "end"{
                //                try audioSession.setCategory(AVAudioSessionCategoryAmbient)
                try audioSession.setActive(false)
                print("set end")
            }
        }
        catch let error as NSError {
            print("Unable to activate audio session:  \(error.localizedDescription)")
            return false
        }
        
        return true
    }
    
    func startRecording(){
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        if !self.audioSet("record") {
            print("cannot set to record mode")
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
                print("is recording" + (result?.bestTranscription.formattedString)!)
                self.recogResult = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                self.audioEngine.inputNode?.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                //                self.isEnabled = true
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
    
    
    //    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
    //        if available {
    //            self.isEnabled = true
    //        } else {
    //            self.isEnabled = false
    //        }
    //    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance){
        print("finished", utterance.speechString)
        semaphore.signal()
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance){
        print("started", utterance.speechString)
        
    }
    
    
    func mainMenu(){
        if self.synth.isSpeaking {
            print("isSpeaking")
//            self.synth.stopSpeaking(at: AVSpeechBoundary.word)
//            self.semaphore.signal()
            return
        }
        else if self.audioEngine.isRunning{
            self.recogTapped()
            self.playAudio("end")
            if !inMode1 {
                if self.recogResult != nil{
//                self.speak(self.recogResult!, rate: 0.45)
                    menuCondition()
                }
            }
        }
        else{
            if inMode1 {
                return
            }
            queue.async {
                self.speak("請在逼聲後念數字來選擇，，再按按鈕結束，，或搖動手機直接進行語音輸入。。。。功能：，一、新增筆記，，二、列出、選擇筆記",rate: 0.53)
                self.playAudio("start")
            }
            queue.asyncAfter(deadline: DispatchTime.now() + .seconds(5), execute: {
                print("enter")
                
                self.recogTapped()
            })
        }
    }
    
    func shake(){
        if self.audioEngine.isRunning{
            self.recogTapped()
            self.playAudio("end")
            if !inMode1{
                if self.recogResult != nil{
//                    self.speak(self.recogResult!, rate: 0.45)
                    menuCondition()
                }
            }
            return
        }
        if !inMode1{
        queue.async{
            self.playAudio("start")
        }
        queue.asyncAfter(deadline: DispatchTime.now() + .seconds(1), execute: {
            print("enter")
            self.recogTapped()
        })
        }

    }
    
    func menuCondition(){
        let rg = self.recogResult!
        if rg.range(of: "一") != nil || rg.range(of: "新增") != nil {
            inMode1 = true
            menu("1")
           
        }
        else if rg.range(of: "二") != nil || rg.range(of: "列出" ) != nil || rg.range(of: "選擇") != nil{
            menu("2")
        }
        else {
            queue.async{
                self.speak("請輸入正確的選項。。", rate : 0.5)
                self.playAudio("start")
            }
            queue.asyncAfter(deadline: DispatchTime.now() + .seconds(5), execute: {
                self.recogTapped()
                while !self.recognitionTask!.isFinishing{}
            })
            
        }
    }
    func menu(_ mode : String){
        if mode == "1" {
            print("Enter mode 1")
            queue.async{
                self.speak("搖動來結束語音輸入。。。。請念出筆記內容：", rate : 0.5)
                self.playAudio("start")
            }
            
            queue.asyncAfter(deadline: DispatchTime.now() + .seconds(5), execute: {
                print("enter")
                self.recogTapped()
            })
            print("End mode 1")
//            queue.asyncAfter(deadline: DispatchTime.now() + .seconds(5), execute: {
//                print("çççççççççenter@@@")
//                self.speak("請念出標籤二：", rate : 0.5)
//                self.playAudio("start")
//            })

            
            
        }
        else if mode == "2" {
            print("Enter mode 2" )
            if TextNote.tagsOfSavedNotes().count == 0 {
                speak("目前沒有筆記", rate: 0.5)
                return
            }
            var text = "共"+String(TextNote.tagsOfSavedNotes().count)+"則筆記。。。"
            for (index, tags) in TextNote.tagsOfSavedNotes().enumerated(){
                text += "第"+String(index+1)+"則筆記，，有關，，，，"
                for tag in tags{
                    text += tag + "，，"
                }
                text += "。。。。"
            }
            print(text)
            queue.async{
                self.speak(text, rate:0.5)
            }
        }
    }
    
    
    
    func recogTapped() {
        print("ΩΩΩΩΩ recog tapped ΩΩΩΩΩΩ")
        print("result now"+(self.recogResult ?? "nil"))
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            self.semaphore.signal()
            print("End Recording...")
        } else {
            self.semaphore.wait()
            while !self.audioSet("record") {
                print("cannot set to play mode")
            }
            self.startRecording()
        }
        
    }
    func playAudio(_ file :String) {
        self.semaphore.wait()
        let alertSound = URL(fileURLWithPath: Bundle.main.path(forResource: file, ofType: "mp3")!)
        print(alertSound)
        
        while !self.audioSet("play") {
            print("cannot set to play mode")
        }
        
        try! audioPlayer = AVAudioPlayer(contentsOf: alertSound)
        audioPlayer!.prepareToPlay()
        audioPlayer!.play()
        while self.audioPlayer!.isPlaying{
        }
        print("play end")
        self.semaphore.signal()
    }
    func speak(_ sender: String,rate r : Float) {
        self.semaphore.wait()
        if !self.audioSet("play")  {
            print ("cannot set to play mode")
        }
        myUtterance = AVSpeechUtterance(string: sender)
        myUtterance.voice =  AVSpeechSynthesisVoice(language: "zh")
        myUtterance.rate = r
        myUtterance.volume = 1.0
        synth.speak(myUtterance)
        print("speaking " + sender)
    }
    
}

