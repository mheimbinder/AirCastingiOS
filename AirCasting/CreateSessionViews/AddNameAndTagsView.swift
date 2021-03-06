//
//  AddNameAndTagsView.swift
//  AirCasting
//
//  Created by Anna Olak on 24/02/2021.
//

import SwiftUI
import CoreLocation

struct AddNameAndTagsView: View {
    @State var sessionName: String = ""
    @State var sessionTags: String = ""
    @State var isIndoor = true
    @State var isWiFi = false
    @State var isWifiPopupPresented = false
    @State var wifiPassword: String = ""
    @State var wifiSSID: String = ""
    @State private var isConfirmCreatingSessionActive: Bool = false
    @EnvironmentObject private var sessionContext: CreateSessionContext

    var body: some View {
        VStack(spacing: 100) {
            VStack(alignment: .leading, spacing: 30) {
                ProgressView(value: 0.75)
                titleLabel
                VStack(spacing: 20) {
                    createTextfield(placeholder: "Session name", binding: $sessionName)
                    createTextfield(placeholder: "Tags", binding: $sessionTags)
                }
                placementPicker
                transmissionTypePicker
            }
            continueButton
        }
        .padding()
    }
    
    var continueButton: some View {
        Button(action: {
            sessionContext.sessionName = sessionName
            sessionContext.sessionTags = sessionTags
            getAndSaveStartingLocation()
            isConfirmCreatingSessionActive = true
            if wifiSSID != "" && wifiPassword != "" {
                sessionContext.wifiSSID = wifiSSID
                sessionContext.wifiPassword = wifiPassword
            }
        }, label: {
            Text("Continue")
                .frame(maxWidth: .infinity)
        })
        .buttonStyle(BlueButtonStyle())
        .background( Group {
            NavigationLink(
                destination: ConfirmCreatingSessionView(sessionName: sessionName),
                isActive: $isConfirmCreatingSessionActive,
                label: {
                    EmptyView()
                })
        })
    }
    
    var titleLabel: some View {
        Text("New session details")
            .font(Font.moderate(size: 24, weight: .bold))
            .foregroundColor(.darkBlue)
    }
    
    var placementPicker: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Where will you place your AirBeam?")
                .font(Font.moderate(size: 16, weight: .bold))
                .foregroundColor(.aircastingDarkGray)
            Picker(selection: $isIndoor,
                   label: Text("")) {
                Text("Indoor").tag(true)
                Text("Outdoor").tag(false)
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }
    
    var transmissionTypePicker: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Data transmission:")
                .font(Font.moderate(size: 16, weight: .bold))
                .foregroundColor(.aircastingDarkGray)
            Picker(selection: $isWiFi,
                   label: Text("")) {
                Text("Cellular").tag(false)
                Text("Wi-Fi").tag(true)
            }
            .pickerStyle(SegmentedPickerStyle())
            .onChange(of: isWiFi) { (_) in
                isWifiPopupPresented = isWiFi
            }
        }
        .sheet(isPresented: $isWifiPopupPresented) {
            WifiPopupView(wifiPassword: $wifiPassword, wifiSSID: $wifiSSID)
        }
    }
    
    func getAndSaveStartingLocation() {
        let fakeLocation = CLLocationCoordinate2D(latitude: 200.0, longitude: 200.0)
        if isIndoor {
            sessionContext.startingLocation = fakeLocation
        } else {
            sessionContext.obtainCurrentLocation()
        }
    }

}

struct AddNameAndTagsView_Previews: PreviewProvider {
    static var previews: some View {
        AddNameAndTagsView()
    }
}
