import SwiftUI

struct ContentView: View {
    @StateObject private var librarySystem = LibraryViewModel()
    
    var body: some View {
        NavigationView {
            List(librarySystem.resources) { resource in
                NavigationLink(destination: ResourceDetailView(resource: resource)) {
                    VStack(alignment: .leading) {
                        Text(resource.title).font(.headline)
                        Text(resource.isAvailable ? "Available" : "Borrowed")
                            .foregroundColor(resource.isAvailable ? .green : .red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Library System")
        }
    }
}

struct ResourceDetailView: View {
    @ObservedObject var resource: LibraryResource
    @State private var alertMessage = ""
    @State private var showAlert = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text(resource.title).font(.largeTitle).multilineTextAlignment(.center)
            
            if let book = resource as? PrintedBook {
                Text("Author: \(book.author)")
                Text("ISBN: \(book.isbn)")
            } else if let journal = resource as? AcademicJournal {
                Text("Volume \(journal.volume), Issue \(journal.issue)")
                if journal.isLibraryOnly {
                    Text("⚠️ In-Library Use Only").foregroundColor(.orange)
                }
            }
            
            Spacer()
            
            Button(action: handleBorrow) {
                Text("Borrow / Access")
                    .frame(maxWidth: .infinity).padding()
                    .background(Color.blue).foregroundColor(.white).cornerRadius(10)
            }
            
            Button(action: handleReturn) {
                Text("Return Resource")
                    .frame(maxWidth: .infinity).padding()
                    .background(Color.gray).foregroundColor(.white).cornerRadius(10)
            }
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(title: Text("System Message"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    func handleBorrow() {
        do {
            alertMessage = try resource.borrowResource()
            showAlert = true
        } catch {
            alertMessage = error.localizedDescription
            showAlert = true
        }
    }
    
    func handleReturn() {
        resource.returnResource()
        alertMessage = "Resource returned successfully."
        showAlert = true
    }
}
