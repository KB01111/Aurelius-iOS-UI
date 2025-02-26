import SwiftUI

// MARK: - Supporting Views

// Component Views
struct StockCard: View {
    let stock: Stock
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(stock.symbol)
                .font(.headline)
            
            Text(stock.name)
                .font(.caption)
                .foregroundColor(.gray)
                .lineLimit(1)
            
            Spacer()
            
            MiniStockChart(data: stock.priceHistory)
                .frame(height: 40)
            
            HStack {
                Text("$\(String(format: "%.2f", stock.price))")
                    .font(.subheadline)
                
                Spacer()
                
                Text("\(stock.percentChange >= 0 ? "+" : "")\(String(format: "%.2f", stock.percentChange))%")
                    .font(.caption)
                    .foregroundColor(stock.percentChange >= 0 ? .green : .red)
            }
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct NewsItemRow: View {
    let item: NewsItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(item.source)
                    .font(.caption)
                    .padding(5)
                    .background(Color(.systemGray6))
                    .cornerRadius(5)
                
                Spacer()
                
                Text(timeAgo(from: item.timestamp))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Text(item.title)
                .font(.subheadline)
                .lineLimit(2)
            
            HStack {
                // Sentiment indicator
                HStack(spacing: 4) {
                    Circle()
                        .fill(sentimentColor(score: item.sentimentScore))
                        .frame(width: 8, height: 8)
                    
                    Text(sentimentText(score: item.sentimentScore))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text("Read more")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .padding(10)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private func timeAgo(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
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
}

struct StockSearchRow: View {
    let stock: Stock
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(stock.symbol)
                    .font(.headline)
                
                Text(stock.name)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("$\(String(format: "%.2f", stock.price))")
                    .font(.headline)
                
                Text("\(stock.percentChange >= 0 ? "+" : "")\(String(format: "%.2f", stock.percentChange))%")
                    .font(.subheadline)
                    .foregroundColor(stock.percentChange >= 0 ? .green : .red)
            }
        }
    }
}

struct HoldingRow: View {
    let holding: Holding
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(holding.stock.symbol)
                    .font(.headline)
                
                Text("\(holding.shares) shares")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("$\(String(format: "%.2f", holding.stock.price * Double(holding.shares)))")
                    .font(.headline)
                
                Text("\(holding.stock.percentChange >= 0 ? "+" : "")\(String(format: "%.2f", holding.stock.percentChange))%")
                    .font(.subheadline)
                    .foregroundColor(holding.stock.percentChange >= 0 ? .green : .red)
            }
        }
    }
}

struct ChangeLabel: View {
    let title: String
    let value: Double
    let isPercentage: Bool
    
    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            
            HStack(spacing: 4) {
                Image(systemName: value >= 0 ? "arrow.up" : "arrow.down")
                
                Text("\(value >= 0 ? "+" : "")\(String(format: "%.2f", value))\(isPercentage ? "%" : "")")
            }
            .font(.subheadline)
            .foregroundColor(value >= 0 ? .green : .red)
        }
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
            }
            
            Text(message.text)
                .padding(12)
                .background(message.isUser ? Color.blue : Color(.systemGray6))
                .foregroundColor(message.isUser ? .white : .primary)
                .cornerRadius(18)
                .padding(message.isUser ? .leading : .trailing, 60)
            
            if !message.isUser {
                Spacer()
            }
        }
    }
}

struct AddToWatchlistButton: View {
    let stock: Stock
    @EnvironmentObject var portfolioManager: PortfolioManager
    @State private var isInWatchlist = false
    
    var body: some View {
        Button(action: toggleWatchlist) {
            Image(systemName: isInWatchlist ? "star.fill" : "star")
                .foregroundColor(isInWatchlist ? .yellow : .gray)
        }
        .onAppear {
            isInWatchlist = portfolioManager.isInWatchlist(stock)
        }
    }
    
    private func toggleWatchlist() {
        if isInWatchlist {
            portfolioManager.removeFromWatchlist(stock)
        } else {
            portfolioManager.addToWatchlist(stock)
        }
        
        isInWatchlist.toggle()
    }
}

// MARK: - Chart Components
struct MarketIndexChart: View {
    let indexName: String
    @State private var data: [Double] = []
    
    var body: some View {
        VStack {
            if data.isEmpty {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            } else {
                // Simple chart visualization
                GeometryReader { geometry in
                    Path { path in
                        let width = geometry.size.width
                        let height = geometry.size.height
                        let step = width / CGFloat(data.count - 1)
                        let min = data.min() ?? 0
                        let max = data.max() ?? 1
                        let scale = height / CGFloat(max - min)
                        
                        path.move(to: CGPoint(x: 0, y: height - CGFloat(data[0] - min) * scale))
                        
                        for i in 1..<data.count {
                            path.addLine(to: CGPoint(
                                x: step * CGFloat(i),
                                y: height - CGFloat(data[i] - min) * scale
                            ))
                        }
                    }
                    .stroke(Color.blue, lineWidth: 2)
                }
            }
        }
        .onAppear {
            loadData()
        }
    }
    
    private func loadData() {
        // Simulate loading market index data
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Generate random data for visualization
            data = (0..<30).map { _ in Double.random(in: 3500...4500) }
        }
    }
}

struct StockChart: View {
    let stock: Stock
    let timeframe: String
    @State private var chartData: [Double] = []
    
    var body: some View {
        VStack {
            if chartData.isEmpty {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            } else {
                // Simple chart visualization
                GeometryReader { geometry in
                    Path { path in
                        let width = geometry.size.width
                        let height = geometry.size.height
                        let step = width / CGFloat(chartData.count - 1)
                        let min = chartData.min() ?? 0
                        let max = chartData.max() ?? 1
                        let scale = height / CGFloat(max - min)
                        
                        path.move(to: CGPoint(x: 0, y: height - CGFloat(chartData[0] - min) * scale))
                        
                        for i in 1..<chartData.count {
                            path.addLine(to: CGPoint(
                                x: step * CGFloat(i),
                                y: height - CGFloat(chartData[i] - min) * scale
                            ))
                        }
                    }
                    .stroke(Color.blue, lineWidth: 2)
                }
            }
        }
        .onAppear {
            loadChartData()
        }
        .onChange(of: timeframe) { _ in
            loadChartData()
        }
    }
    
    private func loadChartData() {
        // Reset and load new data
        chartData = []
        
        // Simulate loading chart data with delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Generate random data points based on timeframe
            let count: Int
            switch timeframe {
            case "1D": count = 24
            case "1W": count = 7
            case "1M": count = 30
            case "3M": count = 90
            case "1Y": count = 252
            case "5Y": count = 60
            default: count = 30
            }
            
            // Generate chart data with some randomness but trending in the direction of percent change
            let trend = stock.percentChange > 0 ? 1.0 : -1.0
            let volatility = 0.5
            
            var price = stock.price - (stock.price * stock.percentChange / 100.0)
            var data: [Double] = [price]
            
            for _ in 1..<count {
                let change = price * Double.random(in: -volatility...volatility) / 100.0
                price += change + (price * trend * abs(stock.percentChange) / 100.0 / Double(count))
                data.append(price)
            }
            
            chartData = data
        }
    }
}

struct MiniStockChart: View {
    let data: [Double]
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                let step = width / CGFloat(data.count - 1)
                let min = data.min() ?? 0
                let max = data.max() ?? 1
                let scale = height / CGFloat(max - min)
                
                path.move(to: CGPoint(x: 0, y: height - CGFloat(data[0] - min) * scale))
                
                for i in 1..<data.count {
                    path.addLine(to: CGPoint(
                        x: step * CGFloat(i),
                        y: height - CGFloat(data[i] - min) * scale
                    ))
                }
            }
            .stroke(lineColor, lineWidth: 1.5)
        }
    }
    
    private var lineColor: Color {
        if let first = data.first, let last = data.last {
            return last >= first ? .green : .red
        }
        return .blue
    }
}

// MARK: - Tab Content Views
struct StockOverviewTab: View {
    let stock: Stock
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Key Statistics
            Group {
                Text("Key Statistics")
                    .font(.headline)
                    .padding(.horizontal)
                
                VStack(spacing: 12) {
                    StatRow(label: "Market Cap", value: "$\(formatNumber(stock.marketCap))")
                    StatRow(label: "P/E Ratio", value: String(format: "%.2f", stock.peRatio))
                    StatRow(label: "52 Week High", value: "$\(String(format: "%.2f", stock.yearHigh))")
                    StatRow(label: "52 Week Low", value: "$\(String(format: "%.2f", stock.yearLow))")
                    StatRow(label: "Avg. Volume", value: formatNumber(stock.avgVolume))
                    StatRow(label: "Dividend Yield", value: "\(String(format: "%.2f", stock.dividendYield))%")
                }
                .padding(.horizontal)
            }
            
            Divider()
            
            // Company Info
            Group {
                Text("About \(stock.name)")
                    .font(.headline)
                    .padding(.horizontal)
                
                Text(stock.description)
                    .font(.body)
                    .padding(.horizontal)
            }
            
            Divider()
            
            // Analyst Recommendations
            Group {
                Text("Analyst Recommendations")
                    .font(.headline)
                    .padding(.horizontal)
                
                HStack(spacing: 0) {
                    AnalystRating(rating: "Buy", percentage: stock.analystRatings.buy, color: .green)
                    AnalystRating(rating: "Hold", percentage: stock.analystRatings.hold, color: .yellow)
                    AnalystRating(rating: "Sell", percentage: stock.analystRatings.sell, color: .red)
                }
                .frame(height: 30)
                .cornerRadius(5)
                .padding(.horizontal)
                
                HStack {
                    Text("Target Price: $\(String(format: "%.2f", stock.targetPrice))")
                    
                    Spacer()
                    
                    if stock.targetPrice > stock.price {
                        Text("\(String(format: "%.1f", (stock.targetPrice - stock.price) / stock.price * 100))% Upside")
                            .foregroundColor(.green)
                    } else {
                        Text("\(String(format: "%.1f", (stock.price - stock.targetPrice) / stock.price * 100))% Downside")
                            .foregroundColor(.red)
                    }
                }
                .font(.subheadline)
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
    
    private func formatNumber(_ number: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        if number >= 1_000_000_000 {
            return "\(String(format: "%.2f", number / 1_000_000_000))B"
        } else if number >= 1_000_000 {
            return "\(String(format: "%.2f", number / 1_000_000))M"
        } else if number >= 1_000 {
            return "\(String(format: "%.2f", number / 1_000))K"
        } else {
            return "\(Int(number))"
        }
    }
}

struct StatRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.gray)
            
            Spacer()
            
            Text(value)
                .fontWeight(.medium)
        }
    }
}

struct AnalystRating: View {
    let rating: String
    let percentage: Double
    let color: Color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(color)
                    .frame(width: geometry.size.width * CGFloat(percentage) / 100)
                
                if percentage > 20 {
                    Text("\(rating) \(Int(percentage))%")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.leading, 5)
                }
            }
        }
    }
}

struct StockChartTab: View {
    let stock: Stock
    @State private var selectedIndicator = 0
    @State private var indicatorParameters = 14
    
    let indicators = ["None", "Moving Average", "RSI", "MACD", "Bollinger Bands"]
    
    var body: some View {
        VStack(spacing: 15) {
            // Technical Indicator Selection
            Picker("Indicator", selection: $selectedIndicator) {
                ForEach(0..<indicators.count, id: \.self) { index in
                    Text(indicators[index]).tag(index)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            if selectedIndicator != 0 {
                // Indicator Parameter Adjustment
                HStack {
                    Text("Period: \(indicatorParameters)")
                        .font(.caption)
                    
                    Slider(value: Binding(
                        get: { Double(indicatorParameters) },
                        set: { indicatorParameters = Int($0) }
                    ), in: 5...50, step: 1)
                }
                .padding(.horizontal)
            }
            
            // Enhanced Stock Chart with Indicators
            EnhancedStockChart(
                stock: stock,
                indicator: indicators[selectedIndicator],
                period: indicatorParameters
            )
            .frame(height: 300)
            .padding()
            
            // Volume Bars
            VolumeChart(stock: stock)
                .frame(height: 100)
                .padding(.horizontal)
            
            Divider()
            
            // Key Price Levels
            VStack(alignment: .leading) {
                Text("Key Levels")
                    .font(.headline)
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Support")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Text("$\(String(format: "%.2f", stock.price * 0.95))")
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("Resistance")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Text("$\(String(format: "%.2f", stock.price * 1.05))")
                    }
                }
            }
            .padding()
        }
    }
}

struct EnhancedStockChart: View {
    let stock: Stock
    let indicator: String
    let period: Int
    @State private var chartData: [Double] = []
    @State private var indicatorData: [Double] = []
    
    var body: some View {
        VStack {
            if chartData.isEmpty {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            } else {
                ZStack {
                    // Price chart
                    GeometryReader { geometry in
                        Path { path in
                            drawLine(data: chartData, geometry: geometry, path: &path)
                        }
                        .stroke(Color.blue, lineWidth: 2)
                        
                        // Indicator overlay if applicable
                        if !indicatorData.isEmpty {
                            Path { path in
                                drawLine(data: indicatorData, geometry: geometry, path: &path)
                            }
                            .stroke(Color.orange, lineWidth: 1.5)
                        }
                    }
                }
            }
        }
        .onAppear {
            loadChartData()
        }
        .onChange(of: indicator) { _ in
            loadChartData()
        }
        .onChange(of: period) { _ in
            calculateIndicator()
        }
    }
    
    private func drawLine(data: [Double], geometry: GeometryProxy, path: inout Path) {
        let width = geometry.size.width
        let height = geometry.size.height
        let step = width / CGFloat(data.count - 1)
        let min = (chartData + indicatorData).min() ?? 0
        let max = (chartData + indicatorData).max() ?? 1
        let scale = height / CGFloat(max - min)
        
        path.move(to: CGPoint(x: 0, y: height - CGFloat(data[0] - min) * scale))
        
        for i in 1..<data.count {
            path.addLine(to: CGPoint(
                x: step * CGFloat(i),
                y: height - CGFloat(data[i] - min) * scale
            ))
        }
    }
    
    private func loadChartData() {
        // Reset data
        chartData = []
        indicatorData = []
        
        // Simulate loading chart data
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Generate sample price data
            self.chartData = (0..<100).map { i in
                let basePrice = stock.price
                let trend = stock.percentChange / 100.0
                let volatility = 0.01
                return basePrice * (1 + trend * Double(i) / 100.0 + Double.random(in: -volatility...volatility))
            }
            
            self.calculateIndicator()
        }
    }
    
    private func calculateIndicator() {
        guard !chartData.isEmpty else { return }
        
        // Calculate the selected indicator
        switch indicator {
        case "Moving Average":
            calculateMovingAverage(period: period)
        case "RSI":
            calculateRSI(period: period)
        case "MACD":
            calculateMACD()
        case "Bollinger Bands":
            calculateBollingerBands(period: period)
        default:
            indicatorData = []
        }
    }
    
    private func calculateMovingAverage(period: Int) {
        guard chartData.count > period else {
            indicatorData = []
            return
        }
        
        // Simple moving average calculation
        var ma: [Double] = []
        
        // Padding with zeroes for alignment
        for _ in 0..<period-1 {
            ma.append(0)
        }
        
        for i in 0...(chartData.count - period) {
            let sum = chartData[i..<(i+period)].reduce(0, +)
            ma.append(sum / Double(period))
        }
        
        indicatorData = ma
    }
    
    private func calculateRSI(period: Int) {
        // This is a simplified RSI calculation for demonstration
        // In a real app, use a proper technical analysis library
        indicatorData = []
    }
    
    private func calculateMACD() {
        // Simplified MACD for demonstration
        indicatorData = []
    }
    
    private func calculateBollingerBands(period: Int) {
        // Simplified Bollinger Bands for demonstration
        indicatorData = []
    }
}

struct VolumeChart: View {
    let stock: Stock
    @State private var volumeData: [Double] = []
    
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .bottom, spacing: 2) {
                ForEach(0..<volumeData.count, id: \.self) { index in
                    Rectangle()
                        .fill(Color.blue.opacity(0.5))
                        .frame(
                            width: (geometry.size.width / CGFloat(volumeData.count + 1)) - 2,
                            height: geometry.size.height * CGFloat(volumeData[index] / (volumeData.max() ?? 1))
                        )
                }
            }
        }
        .onAppear {
            loadVolumeData()
        }
    }
    
    private func loadVolumeData() {
        // Simulate loading volume data
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Generate random volume data
            self.volumeData = (0..<30).map { _ in Double.random(in: 100000...5000000) }
        }
    }
}