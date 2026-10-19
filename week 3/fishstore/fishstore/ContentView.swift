import SwiftUI

struct FishProduct: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let category: String
    let price: Int
    let emoji: String
    let imageName: String
    var oldPrice: Int? = nil
    var isFavorite = false
}

struct CartItem: Identifiable {
    var id: UUID { product.id }
    let product: FishProduct
    var quantity: Int
}

struct FishCategory: Identifiable {
    let name: String
    let emoji: String
    let imageName: String
    var id: String { name }
}

struct ContentView: View {
    @State private var products: [FishProduct] = [
        FishProduct(name: "Cá Hồi đó", category: "Cá cảnh", price: 200000, emoji: "🐠", imageName: "fish_neon"),
        FishProduct(name: "Cây Java Fern", category: "Cây thủy sinh", price: 6000, emoji: "🌿", imageName: "plant_java_fern"),
        FishProduct(name: "Máy lọc nước", category: "Thiết bị lọc", price: 350000, emoji: "🫧", imageName: "filter_machine"),
        FishProduct(name: "Cá Betta", category: "Cá cảnh", price: 25000, emoji: "🐟", imageName: "fish_betta"),
        FishProduct(name: "Thức ăn cá", category: "Thức ăn", price: 45000, emoji: "🪸", imageName: "fish_food"),
        FishProduct(name: "Tép cảnh", category: "Cá cảnh", price: 30000, emoji: "🦐", imageName: "shrimp"),
        FishProduct(name: "Bể cá mini", category: "Phụ kiện", price: 220000, emoji: "🪟", imageName: "mini_tank"),
        FishProduct(name: "Cây thủy sinh", category: "Cây thủy sinh", price: 40000, emoji: "🌱", imageName: "aquatic_plant")
    ]
    @State private var cart: [UUID: CartItem] = [:]
    @State private var selectedTab = 0
    @State private var selectedCategory = "Tất cả"
    @State private var searchText = ""
    @State private var showCart = false
    @State private var showCheckoutAlert = false

    private let categories = [
        FishCategory(name: "Cá cảnh", emoji: "🐠", imageName: "category_fish"),
        FishCategory(name: "Cây thủy sinh", emoji: "🌿", imageName: "category_plants"),
        FishCategory(name: "Phụ kiện", emoji: "🪨", imageName: "category_accessories"),
        FishCategory(name: "Thiết bị lọc", emoji: "🫙", imageName: "category_filter"),
        FishCategory(name: "Thức ăn", emoji: "🧡", imageName: "category_food"),
        FishCategory(name: "Chăm sóc", emoji: "🧴", imageName: "category_care"),
        FishCategory(name: "Tép cảnh", emoji: "🦐", imageName: "category_shrimp"),
        FishCategory(name: "Khuyến mãi", emoji: "🏷️", imageName: "category_sale")
    ]

    private var visibleProducts: [FishProduct] {
        products.filter { product in
            let matchesCategory = selectedCategory == "Tất cả" || product.category == selectedCategory
            let matchesSearch = searchText.isEmpty || product.name.localizedCaseInsensitiveContains(searchText)
            let matchesTab = selectedTab != 2 || product.isFavorite
            return matchesCategory && matchesSearch && matchesTab
        }
    }

    private var cartCount: Int { cart.values.reduce(0) { $0 + $1.quantity } }
    private var cartTotal: Int { cart.values.reduce(0) { $0 + $1.product.price * $1.quantity } }

    var body: some View {
        NavigationStack {
            Group {
                if selectedTab == 3 {
                    ordersView
                } else if selectedTab == 4 {
                    accountView
                } else if selectedTab == 1 {
                    categoryView
                } else {
                    homeView
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .safeAreaInset(edge: .bottom, spacing: 0) { tabBar }
            .sheet(isPresented: $showCart) { cartView }
            .alert("Đặt hàng thành công mới lạ í!", isPresented: $showCheckoutAlert) {
                Button("Đóng", role: .cancel) { }
            } message: {
                Text("Đơn hàng của bạn bị chúng tôi nuốt rồi")
            }
        }
        .tint(Color(red: 0.04, green: 0.36, blue: 0.82))
    }

    private var homeView: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                header
                deliveryRow
                searchBar
                promoBanner
                categorySection
                HStack {
                    Text(selectedTab == 2 ? "Sản phẩm yêu thích" : "Sản phẩm nổi bật")
                        .font(.system(size: 19, weight: .bold))
                    Spacer()
                    Button("Xem tất cả") {
                        selectedTab = 1
                        selectedCategory = "Tất cả"
                    }
                    .font(.system(size: 12, weight: .semibold))
                }
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 14) {
                    ForEach(visibleProducts) { product in
                        productCard(product)
                    }
                }
                if visibleProducts.isEmpty {
                    ContentUnavailableView("Không tìm thấy sản phẩm", systemImage: "magnifyingglass", description: Text("không bán cái này đâu, kiếm khác đi"))
                        .padding(.top, 20)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 20)
        }
        .background(Color(.systemGroupedBackground))
    }

    private var header: some View {
        HStack(spacing: 10) {
            Text("🐠")
                .font(.system(size: 31))
            VStack(alignment: .leading, spacing: 1) {
                Text("HỒ CÓ CÁ BỰ")
                    .font(.system(size: 21, weight: .heavy))
                    .foregroundStyle(Color(red: 0.02, green: 0.28, blue: 0.65))
                Text("Thế giới thủy sinh của THUỶ TINH bắt ở THUỶ CUNG")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button { } label: {
                Image(systemName: "bell")
                    .font(.system(size: 19, weight: .medium))
                    .foregroundStyle(.primary)
                    .overlay(alignment: .topTrailing) { Circle().fill(.red).frame(width: 7, height: 7).offset(x: 2, y: -2) }
            }
            Button { showCart = true } label: {
                Image(systemName: "cart")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(.primary)
                    .overlay(alignment: .topTrailing) {
                        if cartCount > 0 {
                            Text("\(cartCount)").font(.system(size: 9, weight: .bold)).foregroundStyle(.white)
                                .frame(minWidth: 16, minHeight: 16).background(.red, in: Circle()).offset(x: 8, y: -8)
                        }
                    }
            }
        }
        .padding(.vertical, 4)
    }

    private var deliveryRow: some View {
        HStack(spacing: 9) {
            Image(systemName: "mappin.and.ellipse").foregroundStyle(.blue)
            VStack(alignment: .leading, spacing: 2) {
                Text("Giao đến:").font(.system(size: 10)).foregroundStyle(.secondary)
                Text("ĐẠI HỌC QUỐC TẾ, lA2.203").font(.system(size: 12, weight: .semibold))
            }
            Spacer()
            Image(systemName: "chevron.right").font(.system(size: 11, weight: .bold)).foregroundStyle(.secondary)
        }
        .padding(11)
        .background(.white, in: RoundedRectangle(cornerRadius: 13))
    }

    private var searchBar: some View {
        HStack(spacing: 9) {
            Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
            TextField("search đi", text: $searchText)
                .font(.system(size: 13))
                .autocorrectionDisabled()
            if !searchText.isEmpty {
                Button { searchText = "" } label: { Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary) }
            }
            Image(systemName: "viewfinder").foregroundStyle(.secondary)
        }
        .padding(12)
        .background(.white, in: RoundedRectangle(cornerRadius: 13))
    }

    private var promoBanner: some View {
        ZStack(alignment: .leading) {
            Image("banner_home")
                .resizable()
                .scaledToFill()
                .frame(height: 148)
                .clipped()
                .overlay(Color.black.opacity(0.20))
            HStack {
                VStack(alignment: .leading, spacing: 7) {
                    Text("ƯU ĐÃI BỮA NAY ÁAAA").font(.system(size: 10, weight: .heavy)).padding(.horizontal, 9).padding(.vertical, 5).background(.blue, in: Capsule()).foregroundStyle(.white)
                    Text("Cá khỏe ở hồ, đem về chết ngắt").font(.system(size: 20, weight: .heavy)).foregroundStyle(.white)
                    Text("cái gì trên bờ có thì ở đây không có").font(.system(size: 12, weight: .medium)).foregroundStyle(.white)
                }
                Spacer(minLength: 0)
                VStack(spacing: 2) {
                    Text("🐠🐟").font(.system(size: 37))
                    Text("Giảm đến").font(.system(size: 10, weight: .medium))
                    Text("300%").font(.system(size: 25, weight: .black))
                }
                .foregroundStyle(.white)
                .padding(10)
                .background(Color(red: 0.96, green: 0.34, blue: 0.20), in: RoundedRectangle(cornerRadius: 14))
            }
            .padding(15)
        }
        .frame(height: 148)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sản phẩm").font(.system(size: 18, weight: .bold))
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 12) {
                ForEach(categories) { category in
                    Button {
                        selectedTab = 1
                        selectedCategory = category.name == "Khuyến mãi" || category.name == "Chăm sóc" || category.name == "Tép cảnh" ? "Tất cả" : category.name
                    } label: {
                        VStack(spacing: 6) {
                            Image(category.imageName)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .frame(height: 57)
                                .clipped()
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 13))
                            Text(category.name).font(.system(size: 10, weight: .medium)).foregroundStyle(.primary).lineLimit(1).minimumScaleFactor(0.75)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func productCard(_ product: FishProduct) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                Image(product.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 125)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 13))
                Button { toggleFavorite(product) } label: {
                    Image(systemName: product.isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 13, weight: .semibold)).foregroundStyle(product.isFavorite ? .red : .gray)
                        .padding(7).background(.white.opacity(0.95), in: Circle())
                }
                .padding(7)
            }
            .frame(height: 125)
            Text(product.name).font(.system(size: 13, weight: .semibold)).lineLimit(1)
            Text(product.price, format: .number.grouping(.never))
                .font(.system(size: 14, weight: .heavy)).foregroundStyle(.red)
                .overlay(alignment: .trailing) { Text("đ").font(.system(size: 10, weight: .bold)).foregroundStyle(.red).offset(x: 10) }
            Button { addToCart(product) } label: {
                Label("Thêm vào giỏ", systemImage: "cart.badge.plus")
                    .font(.system(size: 11, weight: .semibold)).frame(maxWidth: .infinity).padding(.vertical, 9)
                    .foregroundStyle(.white).background(Color.blue, in: RoundedRectangle(cornerRadius: 9))
            }
        }
        .padding(9)
        .background(.white, in: RoundedRectangle(cornerRadius: 16))
    }

    private var categoryView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Danh mục sản phẩm").font(.system(size: 24, weight: .bold))
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        categoryChip("Tất cả")
                        ForEach(categories) { category in categoryChip(category.name) }
                    }
                }
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                    ForEach(visibleProducts) { product in productCard(product) }
                }
            }
            .padding(16)
        }
        .background(Color(.systemGroupedBackground))
    }

    private func categoryChip(_ title: String) -> some View {
        Button { selectedCategory = title } label: {
            Text(title).font(.system(size: 12, weight: .semibold)).padding(.horizontal, 13).padding(.vertical, 9)
                .foregroundStyle(selectedCategory == title ? .white : .primary)
                .background(selectedCategory == title ? Color.blue : Color.white, in: Capsule())
        }
    }

    private var ordersView: some View {
        VStack(spacing: 15) {
            Image(systemName: "shippingbox").font(.system(size: 52)).foregroundStyle(.blue)
            Text("Đơn hàng của bạn").font(.system(size: 22, weight: .bold))
            Text("Đơn hàng sẽ xuất hiện ở đây sau khi bạn đặt mua sản phẩm.").font(.system(size: 14)).foregroundStyle(.secondary).multilineTextAlignment(.center)
        }
        .padding(30).frame(maxWidth: .infinity, maxHeight: .infinity).background(Color(.systemGroupedBackground))
    }

    private var accountView: some View {
        VStack(spacing: 18) {
            Text("👤").font(.system(size: 58)).padding(20).background(.white, in: Circle())
            Text("Xin chào, khách hàng!").font(.system(size: 22, weight: .bold))
            Text("Đăng nhập để quản lý đơn hàng và thông tin cá nhân.fake news").font(.system(size: 14)).foregroundStyle(.secondary).multilineTextAlignment(.center)
            Button("Đăng nhập / Đăng ký") { }
                .font(.system(size: 15, weight: .bold)).foregroundStyle(.white).frame(maxWidth: .infinity).padding().background(Color.blue, in: RoundedRectangle(cornerRadius: 14))
        }
        .padding(24).frame(maxWidth: .infinity, maxHeight: .infinity).background(Color(.systemGroupedBackground))
    }

    private var cartView: some View {
        NavigationStack {
            Group {
                if cart.isEmpty {
                    ContentUnavailableView("có mua cái gì đâu mà vô đây coi", systemImage: "cart", description: Text("mua đi mua đi "))
                } else {
                    List {
                        ForEach(Array(cart.values)) { item in
                            HStack(spacing: 12) {
                                Image(item.product.imageName)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 55, height: 55)
                                    .clipped()
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(item.product.name).font(.system(size: 14, weight: .semibold))
                                    Text(item.product.price.formatted() + " đ").font(.system(size: 13, weight: .bold)).foregroundStyle(.red)
                                    HStack(spacing: 14) {
                                        Button { changeQuantity(item.product, by: -1) } label: { Image(systemName: "minus.circle") }
                                        Text("\(item.quantity)").font(.system(size: 14, weight: .bold))
                                        Button { changeQuantity(item.product, by: 1) } label: { Image(systemName: "plus.circle") }
                                        Spacer()
                                        Button(role: .destructive) { cart.removeValue(forKey: item.product.id) } label: { Image(systemName: "trash") }
                                    }
                                }
                            }
                            .padding(.vertical, 5)
                        }
                    }
                    VStack(spacing: 12) {
                        HStack {
                            Text("Tổng cộng").font(.system(size: 16, weight: .semibold))
                            Spacer()
                            Text(cartTotal.formatted() + " đ").font(.system(size: 20, weight: .heavy)).foregroundStyle(.red)
                        }
                        Button {
                            cart.removeAll()
                            showCart = false
                            showCheckoutAlert = true
                        } label: {
                            Text("Đặt hàng").font(.system(size: 16, weight: .bold)).foregroundStyle(.white).frame(maxWidth: .infinity).padding().background(Color.blue, in: RoundedRectangle(cornerRadius: 13))
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Giỏ hàng")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Đóng") { showCart = false } } }
        }
    }

    private var tabBar: some View {
        HStack(spacing: 0) {
            tabItem("house.fill", title: "Trang chủ", index: 0)
            tabItem("square.grid.2x2", title: "Danh mục", index: 1)
            tabItem("heart", title: "Yêu thích", index: 2)
            tabItem("shippingbox", title: "Đơn hàng", index: 3)
            tabItem("person", title: "Tài khoản", index: 4)
        }
        .padding(.top, 9)
        .padding(.bottom, 5)
        .background(.ultraThinMaterial)
        .overlay(alignment: .top) { Rectangle().fill(Color.black.opacity(0.07)).frame(height: 0.5) }
    }

    private func tabItem(_ symbol: String, title: String, index: Int) -> some View {
        Button {
            selectedTab = index
            if index == 0 { selectedCategory = "Tất cả" }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: symbol).font(.system(size: 18, weight: selectedTab == index ? .semibold : .regular))
                Text(title).font(.system(size: 9, weight: selectedTab == index ? .bold : .regular))
            }
            .foregroundStyle(selectedTab == index ? Color.blue : Color.secondary)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    private func addToCart(_ product: FishProduct) {
        if let item = cart[product.id] {
            cart[product.id] = CartItem(product: product, quantity: item.quantity + 1)
        } else {
            cart[product.id] = CartItem(product: product, quantity: 1)
        }
    }

    private func changeQuantity(_ product: FishProduct, by amount: Int) {
        guard let item = cart[product.id] else { return }
        let newQuantity = item.quantity + amount
        if newQuantity <= 0 { cart.removeValue(forKey: product.id) }
        else { cart[product.id] = CartItem(product: product, quantity: newQuantity) }
    }

    private func toggleFavorite(_ product: FishProduct) {
        guard let index = products.firstIndex(where: { $0.id == product.id }) else { return }
        products[index].isFavorite.toggle()
    }
}

#Preview {
    ContentView()
}
