//
//  CelebrationView.swift
//  habits
//
//  Created by Maria on 11/07/25.
//

import SwiftUI

struct CelebrationView: View {
    @Binding var isShowing: Bool
    @State private var animationScale: CGFloat = 0.1
    @State private var confettiOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var emojiScale: CGFloat = 0.1
    
    let emojis = ["🎉", "🎊", "🏆", "⭐", "🌟", "💫", "✨", "🎯", "🔥", "💪"]
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissCelebration()
                }
            
            // Main celebration content
            VStack(spacing: 30) {
                // Confetti effect
                ZStack {
                    ForEach(0..<20, id: \.self) { index in
                        Text(emojis[index % emojis.count])
                            .font(.title2)
                            .offset(x: CGFloat.random(in: -150...150), y: CGFloat.random(in: -200...200))
                            .opacity(confettiOpacity)
                            .animation(
                                Animation.easeOut(duration: 2)
                                    .delay(Double(index) * 0.1)
                                    .repeatForever(autoreverses: false),
                                value: confettiOpacity
                            )
                    }
                }
                
                // Main celebration card
                VStack(spacing: 20) {
                    Text("🎉")
                        .font(.system(size: 80))
                        .scaleEffect(emojiScale)
                        .animation(.spring(response: 0.6, dampingFraction: 0.6), value: emojiScale)
                    
                    Text("Parabéns!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .opacity(textOpacity)
                        .animation(.easeIn(duration: 0.5).delay(0.3), value: textOpacity)
                    
                    Text("Você completou todos os seus objetivos de hoje!")
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .opacity(textOpacity)
                        .animation(.easeIn(duration: 0.5).delay(0.5), value: textOpacity)
                    
                    Button(action: {
                        dismissCelebration()
                    }) {
                        Text("Continuar")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .cornerRadius(25)
                    }
                    .opacity(textOpacity)
                    .animation(.easeIn(duration: 0.5).delay(0.7), value: textOpacity)
                }
                .padding(40)
                .background(Color(.systemBackground))
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                .scaleEffect(animationScale)
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: animationScale)
            }
        }
        .onAppear {
            startCelebration()
        }
    }
    
    private func startCelebration() {
        // Start animations
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            animationScale = 1.0
            emojiScale = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            confettiOpacity = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            textOpacity = 1.0
        }
    }
    
    private func dismissCelebration() {
        withAnimation(.easeOut(duration: 0.3)) {
            isShowing = false
        }
    }
}

#Preview {
    CelebrationView(isShowing: .constant(true))
} 