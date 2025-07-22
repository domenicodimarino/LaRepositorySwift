//
//  SpeechSynthesizerDelegate.swift
//  CultureHunter
//
//  Created by Giovanni Adinolfi   on 22/07/25.
//
import Foundation
import AVFoundation

class SpeechSynthesizerDelegate: NSObject, AVSpeechSynthesizerDelegate {
    private let onComplete: () -> Void
    private let onStart: () -> Void
    private let onError: (String) -> Void

    init(onComplete: @escaping () -> Void, onStart: @escaping () -> Void, onError: @escaping (String) -> Void) {
        self.onComplete = onComplete
        self.onStart = onStart
        self.onError = onError
        super.init()
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        onStart()
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        onComplete()
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        onError("Lettura annullata")
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        onError("Lettura in pausa")
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        onStart()
    }
}
