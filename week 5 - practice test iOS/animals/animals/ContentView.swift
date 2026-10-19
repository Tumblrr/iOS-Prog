import SwiftUI

// MARK: - Classes
class Animal {
    var name: String
    
    init(name: String) {
        self.name = name
    }
    
    func makeSound() {
        print("Động vật đang kêu...")
    }
}

class Dog: Animal {
    override func makeSound() {
        print("Gâu gâu!")
    }
}

class Cat: Animal {
    override func makeSound() {
        print("Meo meo!")
    }
}

func testAnimals() {
    let myDog = Dog(name: "Milu")
    print(myDog.name)
    myDog.makeSound()
    
    let myCat = Cat(name: "Mimi")
    print(myCat.name)
    myCat.makeSound()
}

// MARK: - SwiftUI View
struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "pawprint.fill")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Xem kết quả ở màn hình Console (phía dưới Xcode)")
                .padding()
        }
        .onAppear {
            // Gọi hàm testAnimals() khi màn hình vừa xuất hiện
            testAnimals()
        }
    }
}

#Preview {
    ContentView()
}
