//
//  MissionTimeView.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 20/07/25.
//
import SwiftUI

struct MissionTimeView: View {
    @Binding var missionHour: Int
    @Binding var missionMinute: Int
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Orario Missione")
                .font(.title.bold())
                .padding(.top, 20)
            
            Text("Scegli l'orario in cui riceverai la missione giornaliera")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
            
            VStack {
                HStack {
                    Picker("Ora", selection: $missionHour) {
                        ForEach(0..<24, id: \.self) { hour in
                            Text("\(hour)").tag(hour)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(width: 100)
                    .clipped()
                    
                    Text(":")
                        .font(.title)
                    
                    Picker("Minuti", selection: $missionMinute) {
                        ForEach(0..<60, id: \.self) { minute in
                            Text(String(format: "%02d", minute)).tag(minute)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(width: 100)
                    .clipped()
                }
                .frame(height: 150)
                
                Text("Ogni giorno alle \(String(format: "%02d", missionHour)):\(String(format: "%02d", missionMinute)) riceverai una nuova missione")
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(16)
            .padding()
            
            Spacer()
            
            Button("Continua") {
                onNext()
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
        .padding()
        .onAppear {
            if missionHour == 0 && missionMinute == 0 {
                missionHour = 17
                missionMinute = 45
            }
        }
    }
}
