//
//  ButtonSwiftUIView.swift
//  math
//
//  Created by maher on 10/02/2022.
//

import SwiftUI

@available(iOS 13.0, *)
struct ButtonMaher : View {
    
    @State var text : String  = "Mahere RAIS"
    @State var strokeWidth : CGFloat = 1
    
    var body : some View {
        Button(action: {
            print ("button pressed !!!")
        }) {
            Text(text)
                .font(.title)
                .fontWeight(.bold)
                .padding([.leading, .trailing], 25)
                .padding([.bottom, .top], 8)
                .foregroundColor(Color.black)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.black, lineWidth: strokeWidth * 2 )
                )
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: SwiftUI.RoundedCornerStyle.continuous))
                .shadow(color: Color.black, radius: 5, x: 0, y: 5)
            
        }
    }
}

@available(iOS 13.0, *)
struct ButtonSwiftUIView: View {
    
    @State var buttonText : String
    @State var slideValue : Float = 0.5
    
    var body: some View {
        
        ZStack {
            Rectangle()
                .foregroundColor(Color.clear)
                .edgesIgnoringSafeArea(.all)
            
            
            VStack {
                Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/) {
                    Text(buttonText)
                        .foregroundColor(Color.gray)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 15)
                        .background(Color.black)
                        .border(Color.gray, width:5)
                        .cornerRadius(/*@START_MENU_TOKEN@*/10.0/*@END_MENU_TOKEN@*/)
                    
                    
                }
                Slider(value: $slideValue)
                    .accentColor(.red)
                
                ButtonMaher()
                ButtonMaher(text: "oui", strokeWidth: 1).padding(.top, 10)
                
                
            }.padding().background(Color.orange)
        }
        
    }
}

@available(iOS 13.0, *)
struct ButtonSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        ButtonSwiftUIView(buttonText: "maher")
            .previewDevice("iPhone 13 mini")
            .background(Color.clear)
    }
}
