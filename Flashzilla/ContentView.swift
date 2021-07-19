//
//  ContentView.swift
//  Flashzilla
//
//  Created by Vladimir on 15.07.2021.
//

import SwiftUI


struct ContentView: View {
    @State private var cards: [Card] = []
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColors
    @Environment(\.accessibilityEnabled) var accessibiblityEnabled
    
    @State private var timeRemaining = 30
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var isActive = true
    @State private var showingEditScreen = false
    @State private var isCorrect = false
    
    var body: some View {
        
        ZStack {
            Image(decorative: "background")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text(timeRemaining > 0 ? "Time: \(timeRemaining)" : "Game Over")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)
                    .background(
                    Capsule()
                        .fill(Color.black)
                        .opacity(0.75)
                    )
                
                ZStack {
                    ForEach(0..<cards.count, id: \.self) { index in
                        CardView(card: self.cards[index]) { isCorrect in

                            self.removeCard(at: index, isCorrect: isCorrect)
                            
                            print("Cards total: \(cards.count)")
                        
                        }
                        .stacked(at: index, in: self.cards.count)
                        // .allowsHitTesting(index == self.cards.count - 1)
                        .accessibility(hidden: index < self.cards.count - 1)
                    }
                }
                .allowsHitTesting(timeRemaining > 0)
                

                
                if cards.isEmpty || timeRemaining == 0 {
                    Button("Start Again", action: resetCards)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(Color.black)
                        .clipShape(Capsule())
                }
            }
            
            VStack {
                HStack {
                    Spacer()
                    
                    Button {
                        self.showingEditScreen = true
                    } label: {
                        Image(systemName: "plus.circle")
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .clipShape(Circle())
                    }

                }
                
                Spacer()
            }
            .foregroundColor(.white)
            .font(.largeTitle)
            .padding()
            
            if differentiateWithoutColors || accessibiblityEnabled {
                VStack {
                    Spacer()
                    
                    HStack {
                        Button(action: {
                            withAnimation {
                                self.removeCard(at: self.cards.count - 1, isCorrect: false)
                            }
                        }) {
                            Image(systemName: "xmark.circle")
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .clipShape(Circle())
                        }
                        .accessibility(label: Text("Wrong"))
                        .accessibility(hint: Text("Mark your answer as being incorrect."))
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                self.removeCard(at: self.cards.count - 1, isCorrect: true)
                            }
                        }) {
                            Image(systemName: "checkmark.circle")
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .clipShape(Circle())
                        }
                        .accessibility(label: Text("Correct"))
                        .accessibility(hint: Text("Mark your answer as being correct."))
                    }
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .padding()
                }
            }
        }
        .onReceive(timer) { time in
            guard self.isActive else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            self.isActive = false
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            if self.cards.isEmpty == false {
                self.isActive = true
            }
        }
        .sheet(isPresented: $showingEditScreen, onDismiss: resetCards) {
            EditCards()
        }
        .onAppear(perform: resetCards)
        
    }
    

    func removeCard(at index: Int, isCorrect: Bool) {
        guard index >= 0 else { return }
        
        let card = cards.remove(at: index)
        
        if isCorrect {
            
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.cards.insert(card, at: 0)
            }
        }
        
        if cards.isEmpty {
            isActive = false
        }
        
    }
    
    func repeatCard(at index: Int) {
        guard index >= 0 else { return }
        
        let newCard = cards[index]
        cards.remove(at: index)
        cards.insert(newCard, at: 0)
    }
    

    
    func resetCards() {
        timeRemaining = 30
        isActive = true
        loadData()
    }
    
    func loadData() {
        if let data = UserDefaults.standard.data(forKey: "Cards") {
            if let decoded = try? JSONDecoder().decode([Card].self, from: data) {
                self.cards = decoded
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension View {
    func stacked(at position: Int, in total: Int) -> some View {
        let offset = CGFloat(total - position)
        return self.offset(CGSize(width: 0, height: offset * 10))
    }
    
}


struct CustomTextView: View {
    let card: Card
    @Binding var isitCorrect: Bool
    
    
    var body: some View {
        Text(card.prompt)
            .background(Color.yellow)
            .onAppear() {
                isitCorrect = isitCorrect
            }
    }
}


