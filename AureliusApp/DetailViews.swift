import SwiftUI

struct StockFinancialsTab: View {
    let stock: Stock
    @State private var selectedStatement = 0
    @State private var selectedPeriod = 0
    
    let statements = ["Income Statement", "Balance Sheet", "Cash Flow"]
    let periods = ["Annual", "Quarterly"]
    
    var body: some View {
        VStack(spacing: 15) {
            // Statement Type Selection
            Picker("Statement", selection: $selectedStatement) {
                ForEach(0..<statements.count, id: \.self) { index in
                    Text(statements[index]).tag(index)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            // Period Selection
            Picker("Period", selection: $selectedPeriod) {
                ForEach(0..<periods.count, id: \.self) { index in
                    Text(periods[index]).tag(index)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            // Financial Statement Table
            ScrollView {
                VStack(spacing: 0) {
                    // Header Row
                    HStack {
                        Text("Item")
                            .frame(width: 150, alignment: .leading)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        ForEach(periodLabels, id: \.self) { period in
                            Text(period)
                                .frame(width: 80, alignment: .trailing)
                                .fontWeight(.bold)
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal)
                    .background(Color(.systemGray6))
                    
                    // Data Rows
                    ForEach(financialItems, id: \.name) { item in
                        VStack(spacing: 0) {
                            Divider()
                            
                            HStack {
                                Text(item.name)
                                    .frame(width: 150, alignment: .leading)
                                
                                Spacer()
                                
                                ForEach(item.values, id: \.self) { value in
                                    Text(formatCurrency(value))
                                        .frame(width: 80, alignment: .trailing)
                                }
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal)
                        }
                    }
                }
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                .padding()
            }
        }
    }
    
    private var periodLabels: [String] {
        let currentYear = Calendar.current.component(.year, from: Date())
        
        if selectedPeriod == 0 { // Annual
            return ["\(currentYear-2)", "\(currentYear-1)", "\(currentYear)"]
        } else { // Quarterly
            return ["Q1 \(currentYear)", "Q2 \(currentYear)", "Q3 \(currentYear)"]
        }
    }
    
    private var financialItems: [FinancialItem] {
        switch selectedStatement {
        case 0: // Income Statement
            return [
                FinancialItem(name: "Revenue", values: [5.43e9, 6.32e9, 7.14e9]),
                FinancialItem(name: "Cost of Revenue", values: [2.21e9, 2.65e9, 2.98e9]),
                FinancialItem(name: "Gross Profit", values: [3.22e9, 3.67e9, 4.16e9]),
                FinancialItem(name: "Operating Expenses", values: [1.87e9, 2.12e9, 2.43e9]),
                FinancialItem(name: "Operating Income", values: [1.35e9, 1.55e9, 1.73e9]),
                FinancialItem(name: "Net Income", values: [0.98e9, 1.12e9, 1.31e9])
            ]
        case 1: // Balance Sheet
            return [
                FinancialItem(name: "Cash & Equivalents", values: [1.72e9, 2.14e9, 2.53e9]),
                FinancialItem(name: "Total Assets", values: [12.45e9, 14.32e9, 16.78e9]),
                FinancialItem(name: "Current Liabilities", values: [3.21e9, 3.87e9, 4.23e9]),
                FinancialItem(name: "Long-term Debt", values: [4.12e9, 4.56e9, 5.12e9]),
                FinancialItem(name: "Total Liabilities", values: [7.33e9, 8.43e9, 9.35e9]),
                FinancialItem(name: "Stockholders' Equity", values: [5.12e9, 5.89e9, 7.43e9])
            ]
        case 2: // Cash Flow
            return [
                FinancialItem(name: "Operating Cash Flow", values: [1.87e9, 2.13e9, 2.41e9]),
                FinancialItem(name: "Capital Expenditure", values: [-0.87e9, -1.12e9, -1.32e9]),
                FinancialItem(name: "Free Cash Flow", values: [1.0e9, 1.01e9, 1.09e9]),
                FinancialItem(name: "Dividends Paid", values: [-0.32e9, -0.41e9, -0.48e9]),
                FinancialItem(name: "Net Borrowings", values: [0.21e9, 0.34e9, -0.12e9]),
                FinancialItem(name: "Net Cash Flow", values: [0.89e9, 0.94e9, 0.49e9])
            ]
        default:
            return []
        }
    }
    
    private func formatCurrency(_ value: Double) -> String {
        if abs(value) >= 1e9 {
            return "\(String(format: "%.1f", value / 1e9))B"
        } else if abs(value) >= 1e6 {
            return "\(String(format: "%.1f", value / 1e6))M"
        } else {
            return "\(String(format: "%.1f", value / 1e3))K"
        }
    }
}

struct StockNewsTab: View {
    let stock: Stock
    @State private var newsItems: [NewsItem] = []
    @State private var isLoading = true
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading news...")
                    .padding()
            } else if newsItems.isEmpty {
                Text("No recent news found for \(stock.symbol)")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List(newsItems) { item in
                    NavigationLink(destination: NewsDetailView(item: item)) {
                        NewsItemRow(item: item)
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .onAppear {
            loadNews()
        }
    }
    
    private func loadNews() {
        // Simulate loading news data
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            newsItems = [
                NewsItem(
                    id: "1",
                    title: "\(stock.name) Reports Better-Than-Expected Earnings",
                    source: "Financial Times",
                    sentimentScore: 0.78,
                    timestamp: Date().addingTimeInterval(-3600 * 5)
                ),
                NewsItem(
                    id: "2",
                    title: "Analysts Upgrade \(stock.symbol) Following Product Launch",
                    source: "Wall Street Journal",
                    sentimentScore: 0.85,
                    timestamp: Date().addingTimeInterval(-3600 * 12)
                ),
                NewsItem(
                    id: "3",
                    title: "\(stock.symbol) Announces Expansion into International Markets",
                    source: "Bloomberg",
                    sentimentScore: 0.72,
                    timestamp: Date().addingTimeInterval(-3600 * 24)
                ),
                NewsItem(
                    id: "4",
                    title: "Industry Challenges May Impact \(stock.name)'s Growth Forecast",
                    source: "Reuters",
                    sentimentScore: 0.45,
                    timestamp: Date().addingTimeInterval(-3600 * 36)
                ),
                NewsItem(
                    id: "5",
                    title: "\(stock.name) CEO Discusses Future Strategy in Interview",
                    source: "CNBC",
                    sentimentScore: 0.65,
                    timestamp: Date().addingTimeInterval(-3600 * 48)
                )
            ]
            
            isLoading = false
        }
    }
}

// MARK: - Additional Views
struct AddHoldingView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataManager: StockDataManager
    @EnvironmentObject var portfolioManager: PortfolioManager
    @State private var searchText = ""
    @State private var searchResults: [Stock] = []
    @State private var selectedStock: Stock?
    @State private var shares: String = ""
    @State private var purchasePrice: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                // Search Section
                VStack(alignment: .leading) {
                    Text("Find Stock")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search by symbol or name", text: $searchText)
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
                }
                
                // Results List
                if !searchResults.isEmpty {
                    List {
                        ForEach(searchResults) { stock in
                            Button(action: {
                                selectedStock = stock
                                purchasePrice = String(format: "%.2f", stock.price)
                            }) {
                                HStack {
                                    StockSearchRow(stock: stock)
                                    
                                    if selectedStock?.id == stock.id {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .listStyle(PlainListStyle())
                    .frame(height: 250)
                }
                
                Spacer()
                
                // Holding Details
                if let stock = selectedStock {
                    VStack(spacing: 20) {
                        Text("Add \(stock.symbol) to Portfolio")
                            .font(.headline)
                        
                        HStack {
                            Text("Shares")
                                .frame(width: 100, alignment: .leading)
                            
                            TextField("Number of shares", text: $shares)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        HStack {
                            Text("Price")
                                .frame(width: 100, alignment: .leading)
                            
                            TextField("Purchase price", text: $purchasePrice)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        // Purchase Summary
                        if let sharesNum = Double(shares), let price = Double(purchasePrice) {
                            VStack(spacing: 5) {
                                HStack {
                                    Text("Total Value")
                                    Spacer()
                                    Text("$\(String(format: "%.2f", sharesNum * price))")
                                        .fontWeight(.bold)
                                }
                                
                                HStack {
                                    Text("Current Price")
                                    Spacer()
                                    Text("$\(String(format: "%.2f", stock.price))")
                                }
                                
                                if price != stock.price {
                                    HStack {
                                        Text("Difference")
                                        Spacer()
                                        Text("\(price > stock.price ? "-" : "+")\(String(format: "%.2f", abs(stock.price - price) * sharesNum))")
                                            .foregroundColor(price > stock.price ? .red : .green)
                                    }
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        }
                        
                        Button(action: addHolding) {
                            Text("Add to Portfolio")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(isFormValid ? Color.blue : Color.gray)
                                .cornerRadius(10)
                        }
                        .disabled(!isFormValid)
                    }
                    .padding()
                } else {
                    Text("Search and select a stock to add to your portfolio")
                        .foregroundColor(.gray)
                        .italic()
                        .padding()
                }
            }
            .navigationTitle("Add Holding")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private var isFormValid: Bool {
        guard let stock = selectedStock,
              let shares = Double(shares),
              let price = Double(purchasePrice) else {
            return false
        }
        
        return shares > 0 && price > 0
    }
    
    private func performSearch() {
        // Simulate search
        dataManager.searchStocks(query: searchText) { results in
            self.searchResults = results
        }
    }
    
    private func addHolding() {
        guard let stock = selectedStock,
              let sharesNum = Double(shares),
              let purchasePrice = Double(purchasePrice) else {
            return
        }
        
        let holding = Holding(
            id: UUID().uuidString,
            stock: stock,
            shares: Int(sharesNum),
            purchasePrice: purchasePrice,
            purchaseDate: Date()
        )
        
        portfolioManager.addHolding(holding)
        presentationMode.wrappedValue.dismiss()
    }
}

struct NewsDetailView: View {
    let item: NewsItem
    @State private var relatedNews: [NewsItem] = []
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                // Header
                VStack(alignment: .leading, spacing: 5) {
                    Text(item.source)
                        .font(.caption)
                        .padding(5)
                        .background(Color(.systemGray6))
                        .cornerRadius(5)
                    
                    Text(item.title)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(formattedDate(item.timestamp))
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    // Sentiment indicator
                    HStack(spacing: 5) {
                        Circle()
                            .fill(sentimentColor(score: item.sentimentScore))
                            .frame(width: 10, height: 10)
                        
                        Text("AI Sentiment: \(sentimentText(score: item.sentimentScore))")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Text("\(Int(item.sentimentScore * 100))%")
                            .foregroundColor(sentimentColor(score: item.sentimentScore))
                            .fontWeight(.bold)
                    }
                    .padding(8)
                    .background(sentimentColor(score: item.sentimentScore).opacity(0.1))
                    .cornerRadius(5)
                }
                .padding()
                
                Divider()
                
                // Article Content (simulated)
                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.\n\nDuis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\n\nSed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.\n\nNemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt.")
                    .padding()
                
                // Key Points (AI-generated)
                VStack(alignment: .leading, spacing: 10) {
                    Text("Key Points")
                        .font(.headline)
                    
                    ForEach(0..<3, id: \.self) { i in
                        HStack(alignment: .top) {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 8))
                                .padding(.top, 6)
                            
                            Text("This is an important point \(i+1) extracted by our AI from the article content.")
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Related News
                if !relatedNews.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Related News")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(relatedNews) { item in
                            NewsItemRow(item: item)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
        .onAppear {
            loadRelatedNews()
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func sentimentColor(score: Double) -> Color {
        if score > 0.6 {
            return .green
        } else if score < 0.4 {
            return .red
        } else {
            return .yellow
        }
    }
    
    private func sentimentText(score: Double) -> String {
        if score > 0.6 {
            return "Bullish"
        } else if score < 0.4 {
            return "Bearish"
        } else {
            return "Neutral"
        }
    }
    
    private func loadRelatedNews() {
        // Simulate loading related news
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            relatedNews = [
                NewsItem(
                    id: "r1",
                    title: "Industry Analysis: Trends and Forecasts for 2025",
                    source: "Bloomberg",
                    sentimentScore: 0.55,
                    timestamp: Date().addingTimeInterval(-3600 * 2)
                ),
                NewsItem(
                    id: "r2",
                    title: "Competition Heats Up in Tech Sector",
                    source: "CNBC",
                    sentimentScore: 0.48,
                    timestamp: Date().addingTimeInterval(-3600 * 10)
                )
            ]
        }
    }
}

struct AlertSettingsView: View {
    @State private var priceAlerts = true
    @State private var newsAlerts = true
    @State private var earningsAlerts = true
    @State private var analystAlerts = false
    @State private var customAlerts: [CustomAlert] = []
    @State private var showingAddAlertSheet = false
    
    var body: some View {
        Form {
            Section(header: Text("Alert Types")) {
                Toggle("Price Changes", isOn: $priceAlerts)
                Toggle("Breaking News", isOn: $newsAlerts)
                Toggle("Earnings Announcements", isOn: $earningsAlerts)
                Toggle("Analyst Ratings", isOn: $analystAlerts)
            }
            
            Section(header: Text("Custom Alerts")) {
                ForEach(customAlerts) { alert in
                    CustomAlertRow(alert: alert)
                }
                .onDelete(perform: deleteAlert)
                
                Button(action: {
                    showingAddAlertSheet = true
                }) {
                    Label("Add Custom Alert", systemImage: "plus")
                }
            }
        }
        .navigationTitle("Alert Settings")
        .sheet(isPresented: $showingAddAlertSheet) {
            AddCustomAlertView { newAlert in
                customAlerts.append(newAlert)
            }
        }
        .onAppear {
            loadSampleAlerts()
        }
    }
    
    private func loadSampleAlerts() {
        customAlerts = [
            CustomAlert(
                id: "1",
                symbol: "AAPL",
                type: .price,
                condition: .above,
                value: 200.0,
                isActive: true
            ),
            CustomAlert(
                id: "2",
                symbol: "MSFT",
                type: .price,
                condition: .below,
                value: 350.0,
                isActive: true
            )
        ]
    }
    
    private func deleteAlert(at offsets: IndexSet) {
        customAlerts.remove(atOffsets: offsets)
    }
}

struct CustomAlertRow: View {
    let alert: CustomAlert
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(alert.symbol)
                    .font(.headline)
                
                Text(alertDescription)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Circle()
                .fill(alert.isActive ? Color.green : Color.gray)
                .frame(width: 10, height: 10)
        }
    }
    
    private var alertDescription: String {
        switch alert.type {
        case .price:
            let condition = alert.condition == .above ? "above" : "below"
            return "Price \(condition) $\(String(format: "%.2f", alert.value))"
        case .volume:
            let condition = alert.condition == .above ? "above" : "below"
            return "Volume \(condition) \(formatNumber(alert.value))"
        case .percentChange:
            let condition = alert.condition == .above ? "up by" : "down by"
            return "Price \(condition) \(String(format: "%.1f", alert.value))%"
        }
    }
    
    private func formatNumber(_ number: Double) -> String {
        if number >= 1_000_000 {
            return "\(String(format: "%.1f", number / 1_000_000))M"
        } else if number >= 1_000 {
            return "\(String(format: "%.1f", number / 1_000))K"
        } else {
            return "\(Int(number))"
        }
    }
}

struct AddCustomAlertView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var symbol = ""
    @State private var selectedType = 0
    @State private var selectedCondition = 0
    @State private var value = ""
    
    let types = ["Price", "Volume", "Percent Change"]
    let conditions = ["Above", "Below"]
    let callback: (CustomAlert) -> Void
    
    init(callback: @escaping (CustomAlert) -> Void) {
        self.callback = callback
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Alert Details")) {
                    TextField("Stock Symbol", text: $symbol)
                        .autocapitalization(.allCharacters)
                    
                    Picker("Alert Type", selection: $selectedType) {
                        ForEach(0..<types.count, id: \.self) { index in
                            Text(types[index]).tag(index)
                        }
                    }
                    
                    Picker("Condition", selection: $selectedCondition) {
                        ForEach(0..<conditions.count, id: \.self) { index in
                            Text(conditions[index]).tag(index)
                        }
                    }
                    
                    TextField("Value", text: $value)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("New Alert")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    saveAlert()
                }
                .disabled(!isValidForm)
            )
        }
    }
    
    private var isValidForm: Bool {
        !symbol.isEmpty && !value.isEmpty && Double(value) != nil
    }
    
    private func saveAlert() {
        guard let numericValue = Double(value) else { return }
        
        let alertType: CustomAlertType
        switch selectedType {
        case 0: alertType = .price
        case 1: alertType = .volume
        case 2: alertType = .percentChange
        default: alertType = .price
        }
        
        let condition: AlertCondition = selectedCondition == 0 ? .above : .below
        
        let newAlert = CustomAlert(
            id: UUID().uuidString,
            symbol: symbol.uppercased(),
            type: alertType,
            condition: condition,
            value: numericValue,
            isActive: true
        )
        
        callback(newAlert)
        presentationMode.wrappedValue.dismiss()
    }
}