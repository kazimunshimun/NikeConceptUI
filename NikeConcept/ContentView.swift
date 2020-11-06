//
//  ContentView.swift
//  NikeConcept
//
//  Created by Anik on 25/10/20.
//

import SwiftUI

struct ContentView: View {
    @StateObject var menuSelector = MenuSelector()
    @State var showSizeView = false
    var body: some View {
        ZStack {
            Color.init(white: 0.95).ignoresSafeArea()
            
            // home view
            HomeView(menuSelector: menuSelector, shoeSizeView: $showSizeView)
            
            if showSizeView {
                // size card view
                SizeSelectionCardView(shoe: menuSelector.shoeChooser.shoes[0], showSizeView: $showSizeView)
            }
        }
        .onAppear {
            menuSelector.selectMenu(menu: menuSelector.menus[0])
        }
    }
}

struct HomeView: View {
    @ObservedObject var menuSelector: MenuSelector
    @Binding var shoeSizeView: Bool
    var body: some View {
        VStack(spacing: 20) {
            // nike logo
            Image("nike_logo")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 60)
                .padding(.top, 8)
            // menu view
            MenusView(menuSelector: menuSelector)
            // Shoes deck view
            ShoesDeckView(shoeChooser: menuSelector.shoeChooser)
            // buy now button
            Button(action: {
                shoeSizeView = true
            }, label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.orange)
                        .frame(width: 200, height: 50)
                        .shadow(color: Color.orange.opacity(0.2), radius: 10, y: 15)
                    Text("Buy Now")
                        .foregroundColor(.white)
                }
                .padding(.vertical)
                
            })
            // favorite view
            FavoritesView(shoeChooser: menuSelector.shoeChooser)
                .padding()
            
            Spacer()
        }
    }
}

struct MenusView: View {
    @ObservedObject var menuSelector: MenuSelector
    var body: some View {
        HStack {
            ForEach(menuSelector.menus) { menu in
                MenuItemView(menu: menu)
                    .padding()
                    .onTapGesture {
                        withAnimation { menuSelector.selectMenu(menu: menu) }
                    }
            }
        }
    }
}

struct MenuItemView: View {
    let menu: MenuItem
    var body: some View {
        VStack(spacing: 4) {
            Text(menu.name)
            
            RoundedRectangle(cornerRadius: 1)
                .frame(height: 2)
                .opacity(menu.selected ? 1.0 : 0.0)
        }
        .foregroundColor(menu.selected ? .orange : .gray)
        .fixedSize()
    }
}

struct ShoesDeckView: View {
    @ObservedObject var shoeChooser: ShoeChooser
    var body: some View {
        ZStack {
            ForEach(Array(stride(from: shoeChooser.shoes.count - 1, through: 0, by: -1)), id: \.self) { i in
                ShoeCardView(shoe: shoeChooser.shoes[i], shoeChooser: shoeChooser)
                    .rotationEffect(i == 0 ? .zero : .degrees(i%2 == 0 ? -5 : 5), anchor: .bottom)
            }
        }
    }
}

struct ShoeCardView: View {
    let shoe: ShoeItem
    @ObservedObject var shoeChooser: ShoeChooser
    
    @State var translation: CGSize = .zero
    @State var endingSwipe = false
    
    var swipeGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                translation = value.translation
            }
            .onEnded { value in
                withAnimation {
                    endingSwipe = true
                    
                    if translation.width > 100 {
                        translation.width = 300
                        //end swipe with delete
                        shoeChooser.endSwipeWithDelete(shoe: shoe)
                    } else if translation.width < -100 {
                        translation.width = -300
                        // end swipe with favorite
                        shoeChooser.endSwipeWithFavorite(shoe: shoe)
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self.translation = .zero
                        self.endingSwipe = false
                    }
                }
            }
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.init(white: 0.97))
                .frame(width: 240, height: 320)
            
            HStack {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
                    .opacity(translation.width > 100 ? 1.0 : 0.0)
                
                Spacer()
                
                Image(systemName: "heart.circle")
                    .foregroundColor(.green)
                    .opacity(translation.width < -100 ? 1.0 : 0.0)
            }
            .frame(width: 210, height: 300, alignment: .top)
            .font(.system(size: 38))
            
            VStack {
                Image(shoe.image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 210)
                
                Text(shoe.name)
                    .font(.system(size: 18, weight: .black))
                    .multilineTextAlignment(.center)
                    .frame(width: 220, height: 50)
                    .fixedSize()
                    .foregroundColor(Color.init(white: 0.4))
                    .animation(.none)
            }
        }
        .offset(x: translation.width)
        .rotationEffect(.degrees(Double(translation.width/240 * 25)), anchor: .bottom)
        .gesture(swipeGesture)
        .opacity(endingSwipe ? 0.0 : 1.0)
    }
}

struct FavoritesView: View {
    @ObservedObject var shoeChooser: ShoeChooser
    var body: some View {
        VStack(alignment: .leading) {
            Text("Favorites")
                .bold()
            
            ScrollView(.horizontal, showsIndicators: false) {
                if shoeChooser.favorites.count > 0 {
                    HStack {
                        ForEach(shoeChooser.favorites) { shoe in
                            FavoriteItemView(shoe: shoe, visibleNow: shoe.id == shoeChooser.shoes[0].id)
                        }
                    }
                } else {
                    Text("")
                        .frame(width: 70, height: 70)
                }
            }
        }
    }
}

struct FavoriteItemView: View {
    let shoe: ShoeItem
    var visibleNow = false
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25.0)
                .fill(Color.white)
                .frame(width: 70, height: 70)
            
            if visibleNow {
                RoundedRectangle(cornerRadius: 25.0)
                    .strokeBorder(Color.orange, lineWidth: 2)
                    .frame(width: 70, height: 70)
            }
            
            Image(shoe.image)
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
        }
    }
}

struct SizeSelectionCardView: View {
    let shoe: ShoeItem
    @Binding var showSizeView: Bool
    @State var startAnimation = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.5).ignoresSafeArea()
            
            Group {
                // card background
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.white)
                    .frame(height: 400)
                    .padding(.horizontal)
                
                VStack(spacing: 24) {
                    // close card button
                    CloseCardButtonView(showSizeView: $showSizeView, startAnimation: $startAnimation)
                    // shoe info
                    ShoeInfoView(shoe: shoe)
                    // size info view
                    SizeInfoView(shoe: shoe)
                    // add to bag button
                    Button(action: {
                        
                    }, label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 22)
                                .fill(Color.orange)
                                .frame(height: 44)
                            Text("Add to bag")
                                .foregroundColor(.white)
                        }
                        .padding(.vertical)
                    })
                }
                .padding(.horizontal, 32)
            }
            .animation(.easeIn(duration: 0.5))
            .offset(y: startAnimation ? 0 : 500)
        }
        .onAppear {
            withAnimation { startAnimation.toggle() }
        }
    }
}

struct CloseCardButtonView: View {
    @Binding var showSizeView: Bool
    @Binding var startAnimation: Bool
    var body: some View {
        HStack {
            Spacer()
            Button(action: {
                withAnimation { startAnimation.toggle() }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.showSizeView = false
                }
            }, label: {
                Image(systemName: "xmark")
                    .padding()
                    .foregroundColor(.black)
            })
        }
    }
}

struct ShoeInfoView: View {
    let shoe: ShoeItem
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Men's shoe")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.gray)
                Text(shoe.name)
                    .font(.system(size: 16, weight: .bold))
            }
            
            Spacer()
            
            Text("\(String.init(format: "%.0f", shoe.price)) $")
                .font(.system(size: 22, weight: .bold))
        }
    }
}

struct SizeInfoView: View {
    let shoe: ShoeItem
    var colums: [GridItem] = [
        GridItem(.fixed(100), spacing: 16),
        GridItem(.fixed(100), spacing: 16),
        GridItem(.fixed(100), spacing: 16)
    ]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Select size")
                .font(.system(size: 12, weight: .light))
            
            LazyVGrid(columns: colums, alignment: .center, spacing: 16) {
                ForEach(Data.shoeSizes, id: \.self) { size in
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(white: 0.95))
                            .frame(height: 36)
                        
                        Text(Data.getShoeSizeText(size: size))
                            .font(.system(size: 14))
                    }
                    .opacity(shoe.availableSize.contains(CGFloat(size)) ? 1.0 : 0.2)
                }
            }
        }
    }
}

struct MenuItem: Identifiable {
    let id = UUID()
    let name: String
    var selected = false
}

struct ShoeItem: Identifiable {
    let id = UUID()
    let name: String
    let image: String
    let price: CGFloat
    let availableSize: [CGFloat]
}

class MenuSelector: ObservableObject {
    @Published var menus = Data.menus
    var selectedMenuIndex = 0
    var shoeChooser = ShoeChooser()
    
    func selectMenu(menu: MenuItem) {
        if let menuIndex = menus.firstIndex(where: { $0.id == menu.id }) {
            if menuIndex != selectedMenuIndex {
                menus[selectedMenuIndex].selected.toggle()
                shoeChooser.chooseShoes(for: menuIndex)
            }
            
            selectedMenuIndex = menuIndex
            menus[menuIndex].selected.toggle()
        }
    }
}

class ShoeChooser: ObservableObject {
    @Published var shoes = Data.shoes
    @Published var favorites: [ShoeItem] = []
    
    func chooseShoes(for menuIndex: Int) {
        var indices: [Int] = []
        
        switch menuIndex {
        case 0:
            indices = [0, 1, 2, 3, 4, 5, 6]
        case 1:
            indices = [6, 4, 3, 1, 5]
        case 2:
            indices = [4, 3, 2, 5, 6]
        default:
            indices = [0, 1, 2, 3, 4, 5, 6]
        }
        
        populateShoeArray(indices: indices)
    }
    
    func populateShoeArray(indices: [Int]) {
        var shoeArray: [ShoeItem] = []
        
        for index in indices {
            shoeArray.append(Data.shoes[index])
        }
        
        shoes = shoeArray
    }
    
    func addToFavorite(shoe: ShoeItem) {
        if !favorites.contains(where: { $0.id == shoe.id }) {
            favorites.append(shoe)
        }
    }
    
    func endSwipeWithFavorite(shoe: ShoeItem) {
        if let shoeIndex = shoes.firstIndex(where: { shoe.id == $0.id }) {
            addToFavorite(shoe: shoe)
            removeShoeFromDeck(index: shoeIndex)
        }
    }
    
    func endSwipeWithDelete(shoe: ShoeItem) {
        if let shoeIndex = shoes.firstIndex(where: { shoe.id == $0.id }) {
            removeShoeFromDeck(index: shoeIndex)
        }
    }
    
    func removeShoeFromDeck(index: Int) {
        if shoes.count == 1 {
            shoes = Data.shoes.shuffled()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.shoes.remove(at: index)
        }
    }
}

struct Data {
    static let menus = [
        MenuItem(name: "Hot"),
        MenuItem(name: "Selling"),
        MenuItem(name: "Pre-sale")
    ]
    
    static let shoes = [
        ShoeItem(name: "Nike Air Zoom Pegasus 37", image: "pegasus_37", price: 250, availableSize: [5.5, 6.0, 7.0, 8.0, 9.5, 10]),
        ShoeItem(name: "Nike Air Zoom Structure 23", image: "structure_23", price: 300, availableSize: [5.5, 6.0, 8.0, 9.5, 10]),
        ShoeItem(name: "Nike React Infinity Run Flyknit", image: "infinity_run", price: 280, availableSize: [7.0, 8.0, 9.5, 10]),
        ShoeItem(name: "Nike Air Zoom Terra Kiger 6", image: "terra_kiger_6", price: 170, availableSize: [5.5, 7.0, 8.0, 10]),
        ShoeItem(name: "Nike Air Zoom vomero 14", image: "vomero_14", price: 120, availableSize: [5.5, 6.0, 7.0, 8.0, 9.5]),
        ShoeItem(name: "Nike Wildhorse 6", image: "wildhorse_6", price: 200, availableSize: [5.5, 6.0, 7.0, 8.0, 9.5, 10.0]),
        ShoeItem(name: "Nike React Phantom Run Flyknit 2", image: "phantom_2", price: 220, availableSize: [6.0, 9.5, 10.0])
    ]
    
    static let shoeSizes = [5.5, 6.0, 6.5, 7.0, 7.5, 8.0, 9.0, 9.5, 10.0]
    
    static func getShoeSizeText(size: Double) -> String {
        switch size {
        case 5.5:
            return "UK 5.5"
        case 6.0:
            return "UK 6"
        case 6.5:
            return "UK 6.5"
        case 7.0:
            return "UK 7"
        case 7.5:
            return "UK 7.5"
        case 8.0:
            return "UK 8"
        case 9.0:
            return "UK 9"
        case 9.5:
            return "UK 9.5"
        case 10.0:
            return "UK 10"
        default:
            return "UK 5.5"
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
