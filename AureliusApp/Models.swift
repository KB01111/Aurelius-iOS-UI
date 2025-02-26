import SwiftUI
import Combine

// MARK: - Data Models
struct Stock: Identifiable {
    let id: String
    let symbol: String
    let name: String
    let price: Double
    let percentChange: Double
    let priceHistory: [Double]
    
    // Additional properties for detail view
    let marketCap: Double
    let peRatio: Double
    let yearHigh: Double
    let yearLow: Double
    let avgVolume: Double
    let dividendYield: Double
    let description: String
    let analystRatings: AnalystRatings
    let targetPrice: Double
    
    init(
        id: String,
        symbol: String,
        name: String,
        price: Double,
        percentChange: Double
    ) {
        self.id = id
        self.symbol = symbol
        self.name = name
        self.price = price
        self.percentChange = percentChange
        
        // Generate random price history for demonstration
        self.priceHistory = (0..<20).map { _ in Double.random(in: price * 0.9...price * 1.1) }
        
        // Default values for additional properties
        self.marketCap = price * Double.random(in: 10_000_000...1_000_000_000)
        self.peRatio = Double.random(in: 10...40)
        self.yearHigh = price * Double.random(in: 1.05...1.3)
        self.yearLow = price * Double.random(in: 0.7...0.95)
        self.avgVolume = Double.random(in: 1_000_000...10_000_000)
        self.dividendYield = Double.random(in: 0...5)
        self.description = "This is a sample description for \(name) (\(symbol)). The company operates in various sectors and has shown significant growth in recent years. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer nec odio."
        self.analystRatings = AnalystRatings(
            buy: Double.random(in: 30...80),
            hold: Double.random(in: 10...50),
            sell: Double.random(in: 0...30)
        )
        self.targetPrice = price * Double.random(in: 0.8...1.2)
    }
}

struct AnalystRatings {
    let buy: Double
    let hold: Double
    let sell: Double
    
    init(buy: Double, hold: Double, sell: Double) {
        let total = buy + hold + sell
        self.buy = buy / total * 100
        self.hold = hold / total * 100
        self.sell = sell / total * 100
    }
}

struct Holding: Identifiable {
    let id: String
    let stock: Stock
    let shares: Int
    let purchasePrice: Double
    let purchaseDate: Date
    
    var currentValue: Double {
        return Double(shares) * stock.price
    }
    
    var gainLoss: Double {
        return currentValue - (Double(shares) * purchasePrice)
    }
    
    var gainLossPercentage: Double {
        return (stock.price - purchasePrice) / purchasePrice * 100
    }
}

struct NewsItem: Identifiable {
    let id: String
    let title: String
    let source: String
    let sentimentScore: Double
    let timestamp: Date
}

struct NewsSource: Identifiable {
    let id: String
    let name: String
    let isEnabled: Bool
}

struct ChatMessage: Identifiable {
    let id: String
    let text: String
    let isUser: Bool
    let timestamp: Date
}

struct CustomAlert: Identifiable {
    let id: String
    let symbol: String
    let type: CustomAlertType
    let condition: AlertCondition
    let value: Double
    let isActive: Bool
}

enum CustomAlertType {
    case price
    case volume
    case percentChange
}

enum AlertCondition {
    case above
    case below
}

struct APIEndpoint: Identifiable {
    let id: String
    let name: String
    let path: String
    let method: String
    let parameters: [Parameter]
}

struct Parameter: Identifiable {
    var id: String { name }
    var name: String
    var type: ParameterType
    var required: Bool
}

enum ParameterType {
    case string
    case number
    case boolean
    case date
}

struct AIProvider: Identifiable {
    let id: String
    let name: String
    let baseURL: String
    let apiKey: String
    let parameters: [String: Double]
}

struct ChatTemplate: Identifiable {
    let id: String
    let name: String
    let prompt: String
}

struct FinancialItem {
    let name: String
    let values: [Double]
}

// MARK: - Data Managers
class StockDataManager: ObservableObject {
    @Published var marketIndexData: [Double] = []
    
    func fetchMarketIndexData(for index: String) {
        // In a real app, this would make an API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Generate sample data for visualization
            self.marketIndexData = (0..<30).map { _ in Double.random(in: 3500...4500) }
        }
    }
    
    func searchStocks(query: String, completion: @escaping ([Stock]) -> Void) {
        // In a real app, this would make an API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // Return some sample stocks that match the query
            let sampleStocks = [
                Stock(id: "AAPL", symbol: "AAPL", name: "Apple Inc.", price: 185.92, percentChange: 1.25),
                Stock(id: "MSFT", symbol: "MSFT", name: "Microsoft Corporation", price: 337.50, percentChange: -0.48),
                Stock(id: "AMZN", symbol: "AMZN", name: "Amazon.com, Inc.", price: 183.05, percentChange: 2.10),
                Stock(id: "GOOGL", symbol: "GOOGL", name: "Alphabet Inc.", price: 142.25, percentChange: 0.75),
                Stock(id: "META", symbol: "META", name: "Meta Platforms, Inc.", price: 378.66, percentChange: -1.22),
                Stock(id: "TSLA", symbol: "TSLA", name: "Tesla, Inc.", price: 215.38, percentChange: 3.42),
                Stock(id: "NVDA", symbol: "NVDA", name: "NVIDIA Corporation", price: 476.35, percentChange: 4.18),
                Stock(id: "JPM", symbol: "JPM", name: "JPMorgan Chase & Co.", price: 156.48, percentChange: -0.33),
                Stock(id: "V", symbol: "V", name: "Visa Inc.", price: 248.53, percentChange: 0.12),
                Stock(id: "WMT", symbol: "WMT", name: "Walmart Inc.", price: 58.78, percentChange: 0.89)
            ]
            
            // Filter stocks based on query
            if query.isEmpty {
                completion([])
            } else {
                let filteredStocks = sampleStocks.filter { stock in
                    stock.symbol.lowercased().contains(query.lowercased()) ||
                    stock.name.lowercased().contains(query.lowercased())
                }
                completion(filteredStocks)
            }
        }
    }
}

class PortfolioManager: ObservableObject {
    @Published var holdings: [Holding] = []
    @Published var watchlist: [Stock] = []
    
    init() {
        // Load sample data
        loadSampleData()
    }
    
    private func loadSampleData() {
        // Sample watchlist
        watchlist = [
            Stock(id: "AAPL", symbol: "AAPL", name: "Apple Inc.", price: 185.92, percentChange: 1.25),
            Stock(id: "MSFT", symbol: "MSFT", name: "Microsoft Corporation", price: 337.50, percentChange: -0.48),
            Stock(id: "GOOGL", symbol: "GOOGL", name: "Alphabet Inc.", price: 142.25, percentChange: 0.75),
            Stock(id: "AMZN", symbol: "AMZN", name: "Amazon.com, Inc.", price: 183.05, percentChange: 2.10)
        ]
        
        // Sample holdings
        holdings = [
            Holding(
                id: "1",
                stock: Stock(id: "AAPL", symbol: "AAPL", name: "Apple Inc.", price: 185.92, percentChange: 1.25),
                shares: 10,
                purchasePrice: 175.50,
                purchaseDate: Date().addingTimeInterval(-30 * 24 * 3600)
            ),
            Holding(
                id: "2",
                stock: Stock(id: "MSFT", symbol: "MSFT", name: "Microsoft Corporation", price: 337.50, percentChange: -0.48),
                shares: 5,
                purchasePrice: 320.25,
                purchaseDate: Date().addingTimeInterval(-60 * 24 * 3600)
            ),
            Holding(
                id: "3",
                stock: Stock(id: "NVDA", symbol: "NVDA", name: "NVIDIA Corporation", price: 476.35, percentChange: 4.18),
                shares: 8,
                purchasePrice: 400.10,
                purchaseDate: Date().addingTimeInterval(-45 * 24 * 3600)
            )
        ]
    }
    
    func addHolding(_ holding: Holding) {
        holdings.append(holding)
    }
    
    func removeHoldings(at offsets: IndexSet) {
        holdings.remove(atOffsets: offsets)
    }
    
    func addToWatchlist(_ stock: Stock) {
        if !isInWatchlist(stock) {
            watchlist.append(stock)
        }
    }
    
    func removeFromWatchlist(_ stock: Stock) {
        watchlist.removeAll { $0.id == stock.id }
    }
    
    func isInWatchlist(_ stock: Stock) -> Bool {
        return watchlist.contains { $0.id == stock.id }
    }
    
    func calculateTotalGain() -> Double {
        let initialInvestment = holdings.reduce(0) { $0 + ($1.purchasePrice * Double($1.shares)) }
        let currentValue = holdings.reduce(0) { $0 + ($1.stock.price * Double($1.shares)) }
        
        if initialInvestment == 0 {
            return 0
        }
        
        return ((currentValue - initialInvestment) / initialInvestment) * 100
    }
}