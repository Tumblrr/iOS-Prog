

import SwiftUI

struct ContentView: View {
    let name = "Tumblrr"
    let studentID = "SESEIU24008"
    let message = "My iOS journey starts today! hehehe"
   
    var body: some View {
            VStack( spacing: 16 ){
                Image("Image")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20,height :20)
                
                Text("Hello, SWift!haha")
                    .font(.largeTitle)
                    .bold()
                
                Text("My name is \(name)")
                    .font(.title2)
                Text("student ID: \(studentID)")
                    .font(.title3)
                Text("\(message)")
                    .font(.title3)
                Image("Image")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20,height :20)
            }
            .padding()
        }
        
    }
