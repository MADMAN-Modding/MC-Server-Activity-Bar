import Playgrounds
import ServiceManagement
import SwiftUI

struct Preferences: View {
    @AppStorage("serverAddress") private var serverAddress: String = ""
    @AppStorage("headsToShow") private var headsToShow: Int = Constants
        .headCount
    @AppStorage("pollingFrequency") private var pollingFrequency: Int =
        Constants.pollingFrequency
    @State private var launchAtLogin = SMAppService.mainApp.status == .enabled

    var body: some View {

        Grid {
            GridRow {
                HStack {
                    Text("Server Address: ")
                    TextField(
                        "Server Address",
                        text: $serverAddress,
                        prompt: Text("Server Address")
                    )
                }
            }.padding(5).contentMargins(5)

            Toggle("Open at login", isOn: $launchAtLogin)
                .onChange(of: launchAtLogin) { _, newValue in
                    setLaunchAtLogin(newValue)
                }

//            GridRow {
//                HStack {
//                    Stepper(
//                        "Menu Bar Heads to Show",
//                        value: $headsToShow,
//                        in: 1...20
//                    )
//                    Text(headsToShow.formatted())
//                }
//            }.padding(5).contentMargins(5)
            GridRow {
                HStack {
                    Stepper(
                        "Polling Frequency (seconds)",
                        value: $pollingFrequency,
                        in: 1...600
                    )
                    Text(pollingFrequency.formatted())
                }
            }.padding(5).contentMargins(5)

            Text("Requires App Restart").foregroundColor(Color.orange).font(
                .caption
            )
        }
    }
}

#Preview {
    Preferences()
}
