import SwiftUI
import Combine

// MARK: - Main App Structure
@main
struct AureliusApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// MARK: - Content View (Main Tab View)
struct ContentView: View {
    @StateObject private var dataManager = StockDataManager()
    @StateObject private var portfolioManager = PortfolioManager()
    
    var body: some View {
        TabView {
            DashboardView()
                .environmentObject(dataManager)
                .environmentObject(portfolioManager)
                .tabItem {
                    Label("Dashboard", systemImage: "chart.line.uptrend.xyaxis")
                }
            
            StockSearchView()
                .environmentObject(dataManager)
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            
            PortfolioView()
                .environmentObject(portfolioManager)
                .tabItem {
                    Label("Portfolio", systemImage: "briefcase")
                }
            
            AIAssistantView()
                .tabItem {
                    Label("AI Chat", systemImage: "bubble.left.and.bubble.right")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .accentColor(.blue)
    }
}

// MARK: - Dashboard View
struct DashboardView: View {
    @EnvironmentObject var dataManager: StockDataManager
    @EnvironmentObject var portfolioManager: PortfolioManager
    @State private var selectedMarketIndex = 0
    @State private var newsItems: [NewsItem] = []
    
    let marketIndices = ["S&P 500", "Dow Jones", "NASDAQ", "Russell 2000"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Market Overview Section
                    VStack(alignment: .leading) {
                        Text("Market Overview")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        Picker("Market Index", selection: $selectedMarketIndex) {
                            ForEach(0..<marketIndices.count, id: \.self) { index in
                                Text(marketIndices[index]).tag(index)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                        
                        MarketIndexChart(indexName: marketIndices[selectedMarketIndex])
                            .frame(height: 250)
                            .padding()
                    }
                    
                    Divider()
                    
                    // Watchlist Section
                    VStack(alignment: .leading) {
                        Text("Watchlist")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(portfolioManager.watchlist) { stock in
                                    StockCard(stock: stock)
                                        .frame(width: 160, height: 140)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    Divider()
                    
                    // Latest News Section
                    VStack(alignment: .leading) {
                        Text("Latest News")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(newsItems) { item in
                            NewsItemRow(item: item)
                                .padding(.horizontal)
                        }
                        
                        if newsItems.isEmpty {
                            Text("Loading news...")
                                .italic()
                                .foregroundColor(.gray)
                                .padding()
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Aurelius")
            .onAppear {
                loadMarketData()
                loadNewsData()
            }
        }
    }
    
    private func loadMarketData() {
        // Simulate loading market data
        dataManager.fetchMarketIndexData(for: marketIndices[selectedMarketIndex])
    }
    
    private func loadNewsData() {
        // Simulate loading news data
        newsItems = [
            NewsItem(id: "1", title: "Fed Signals Potential Rate Cut", source: "Financial Times", sentimentScore: 0.65, timestamp: Date()),
            NewsItem(id: "2", title: "Tech Stocks Rally After Strong Earnings", source: "Wall Street Journal", sentimentScore: 0.82, timestamp: Date().addingTimeInterval(-3600)),
            NewsItem(id: "3", title: "Market Volatility Increases Amid Global Tensions", source: "Bloomberg", sentimentScore: 0.35, timestamp: Date().addingTimeInterval(-7200))
        ]
    }
}

// MARK: - Stock Search View
struct StockSearchView: View {
    @EnvironmentObject var dataManager: StockDataManager
    @State private var searchText = ""
    @State private var searchResults: [Stock] = []
    
    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search stocks by symbol or name", text: $searchText)
                        .onChange(of: searchText) { _ in
                            if !searchText.isEmpty {
                                performSearch()
                            } else {
                                searchResults = []
                            }
                        }
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                            searchResults = []
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Results List
                List {
                    ForEach(searchResults) { stock in
                        NavigationLink(destination: StockDetailView(stock: stock)) {
                            StockSearchRow(stock: stock)
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Stock Search")
        }
    }
    
    private func performSearch() {
        // Simulate search functionality
        dataManager.searchStocks(query: searchText) { results in
            self.searchResults = results
        }
    }
}

// MARK: - Stock Detail View
struct StockDetailView: View {
    let stock: Stock
    @State private var selectedTimeframe = 1
    @State private var selectedTab = 0
    
    let timeframes = ["1D", "1W", "1M", "3M", "1Y", "5Y"]
    let tabTitles = ["Overview", "Chart", "Financials", "News"]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                // Stock Header
                HStack {
                    VStack(alignment: .leading) {
                        Text(stock.name)
                            .font(.headline)
                        Text(stock.symbol)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("$\(String(format: "%.2f", stock.price))")
                            .font(.headline)
                        
                        HStack(spacing: 4) {
                            Image(systemName: stock.percentChange >= 0 ? "arrow.up" : "arrow.down")
                            
                            Text("\(String(format: "%.2f", abs(stock.percentChange)))%")
                                .foregroundColor(stock.percentChange >= 0 ? .green : .red)
                        }
                        .font(.subheadline)
                    }
                }
                .padding()
                
                // Chart Time Frame Selector
                Picker("Timeframe", selection: $selectedTimeframe) {
                    ForEach(0..<timeframes.count, id: \.self) { index in
                        Text(timeframes[index]).tag(index)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Stock Chart
                StockChart(stock: stock, timeframe: timeframes[selectedTimeframe])
                    .frame(height: 250)
                    .padding()
                
                // Tab Selection
                Picker("View", selection: $selectedTab) {
                    ForEach(0..<tabTitles.count, id: \.self) { index in
                        Text(tabTitles[index]).tag(index)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Tab Content
                switch selectedTab {
                case 0:
                    StockOverviewTab(stock: stock)
                case 1:
                    StockChartTab(stock: stock)
                case 2:
                    StockFinancialsTab(stock: stock)
                case 3:
                    StockNewsTab(stock: stock)
                default:
                    EmptyView()
                }
            }
        }
        .navigationTitle(stock.symbol)
        .navigationBarItems(trailing: AddToWatchlistButton(stock: stock))
    }
}

// MARK: - Portfolio View
struct PortfolioView: View {
    @EnvironmentObject var portfolioManager: PortfolioManager
    @State private var showingAddStockSheet = false
    @State private var portfolioValue: Double = 0
    @State private var dailyChange: Double = 0
    @State private var totalGain: Double = 0
    
    var body: some View {
        NavigationView {
            VStack {
                // Portfolio Summary Card
                VStack(spacing: 15) {
                    Text("Portfolio Value")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text("$\(String(format: "%.2f", portfolioValue))")
                        .font(.system(size: 36, weight: .bold))
                    
                    HStack(spacing: 20) {
                        ChangeLabel(title: "Daily", value: dailyChange, isPercentage: true)
                        ChangeLabel(title: "Total Gain", value: totalGain, isPercentage: true)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding()
                
                // Holdings List
                List {
                    ForEach(portfolioManager.holdings) { holding in
                        NavigationLink(destination: StockDetailView(stock: holding.stock)) {
                            HoldingRow(holding: holding)
                        }
                    }
                    .onDelete(perform: deleteHolding)
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Portfolio")
            .navigationBarItems(
                trailing: Button(action: {
                    showingAddStockSheet = true
                }) {
                    Image(systemName: "plus")
                }
            )
            .sheet(isPresented: $showingAddStockSheet) {
                AddHoldingView()
            }
            .onAppear {
                calculatePortfolioMetrics()
            }
        }
    }
    
    private func calculatePortfolioMetrics() {
        portfolioValue = portfolioManager.holdings.reduce(0) { $0 + ($1.stock.price * Double($1.shares)) }
        dailyChange = portfolioManager.holdings.reduce(0) { $0 + ($1.stock.percentChange * ($1.stock.price * Double($1.shares)) / 100) }
        totalGain = portfolioManager.calculateTotalGain()
    }
    
    private func deleteHolding(at offsets: IndexSet) {
        portfolioManager.removeHoldings(at: offsets)
        calculatePortfolioMetrics()
    }
}

// MARK: - AI Assistant View
struct AIAssistantView: View {
    @State private var messageText = ""
    @State private var messages: [ChatMessage] = []
    @State private var isTyping = false
    
    var body: some View {
        VStack {
            // Chat Header
            HStack {
                Text("Aurelius AI Assistant")
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    // Clear chat
                    messages = []
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            
            // Message List
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(messages) { message in
                        MessageBubble(message: message)
                    }
                    
                    if isTyping {
                        HStack(spacing: 4) {
                            ForEach(0..<3) { _ in
                                Circle()
                                    .frame(width: 7, height: 7)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(15)
                        .padding(.leading)
                    }
                }
                .padding()
            }
            
            // Message Input
            HStack {
                TextField("Ask about market data, analysis, news...", text: $messageText)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(messageText.isEmpty ? .gray : .blue)
                }
                .disabled(messageText.isEmpty)
            }
            .padding()
        }
        .onAppear {
            // Add welcome message
            let welcomeMessage = ChatMessage(
                id: UUID().uuidString,
                text: "Hello! I'm your Aurelius AI assistant. I can help you with market research, stock analysis, and investment insights. What would you like to know today?",
                isUser: false,
                timestamp: Date()
            )
            messages.append(welcomeMessage)
        }
    }
    
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        
        // Add user message
        let userMessage = ChatMessage(
            id: UUID().uuidString,
            text: messageText,
            isUser: true,
            timestamp: Date()
        )
        messages.append(userMessage)
        
        // Clear input field
        let userQuery = messageText
        messageText = ""
        
        // Simulate AI response
        isTyping = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let aiResponse = generateAIResponse(to: userQuery)
            let aiMessage = ChatMessage(
                id: UUID().uuidString,
                text: aiResponse,
                isUser: false,
                timestamp: Date()
            )
            self.messages.append(aiMessage)
            self.isTyping = false
        }
    }
    
    private func generateAIResponse(to query: String) -> String {
        // In a real app, this would connect to an AI service
        // This is just a simple simulation
        let responses = [
            "Based on current market trends, tech stocks are showing strong momentum this quarter.",
            "The latest Fed announcement could impact financial sectors. Keep an eye on banking stocks in the coming weeks.",
            "Recent earnings reports for \(query.replacingOccurrences(of: "what do you think about ", with: "").capitalized) are above analyst expectations, showing 12% YoY growth.",
            "From a technical analysis perspective, \(query.replacingOccurrences(of: "how is ", with: "").capitalized) appears to be approaching a resistance level at $342.",
            "Market sentiment for renewable energy is currently bullish according to our analysis of recent news articles.",
            "Analyzing the last 5 years of data, similar market conditions have led to a sector rotation toward defensive stocks."
        ]
        
        return responses.randomElement() ?? "I'll need to research that further. Could you provide more details about what you're looking for?"
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("defaultTimeframe") private var defaultTimeframe = "1D"
    @State private var selectedAPIProvider = 0
    
    let apiProviders = ["Finnhub", "Yahoo Finance", "Alpha Vantage", "Custom"]
    let timeframeOptions = ["1D", "1W", "1M", "3M", "1Y", "5Y"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Appearance")) {
                    Toggle("Dark Mode", isOn: $darkModeEnabled)
                }
                
                Section(header: Text("Notifications")) {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                    
                    if notificationsEnabled {
                        NavigationLink("Configure Alerts", destination: AlertSettingsView())
                    }
                }
                
                Section(header: Text("Chart Settings")) {
                    Picker("Default Timeframe", selection: $defaultTimeframe) {
                        ForEach(timeframeOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                }
                
                Section(header: Text("Data Providers")) {
                    Picker("Market Data Provider", selection: $selectedAPIProvider) {
                        ForEach(0..<apiProviders.count, id: \.self) { index in
                            Text(apiProviders[index]).tag(index)
                        }
                    }
                    
                    if selectedAPIProvider == 3 {
                        NavigationLink("Configure Custom API", destination: CustomAPISettingsView())
                    }
                }
                
                Section(header: Text("AI Settings")) {
                    NavigationLink("AI Provider Settings", destination: AIProviderSettingsView())
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                    
                    NavigationLink("Privacy Policy", destination: WebContentView(urlString: "https://aurelius.example.com/privacy"))
                    
                    NavigationLink("Terms of Service", destination: WebContentView(urlString: "https://aurelius.example.com/terms"))
                }
            }
            .navigationTitle("Settings")
        }
    }
}