import SwiftUI

struct CustomAPISettingsView: View {
    @State private var apiKey = ""
    @State private var baseURL = ""
    @State private var apiEndpoints: [APIEndpoint] = []
    @State private var isEditingEndpoint = false
    @State private var currentEndpoint: APIEndpoint?
    
    var body: some View {
        Form {
            Section(header: Text("API Configuration")) {
                TextField("API Key", text: $apiKey)
                TextField("Base URL", text: $baseURL)
            }
            
            Section(header: Text("API Endpoints")) {
                ForEach(apiEndpoints) { endpoint in
                    Button(action: {
                        currentEndpoint = endpoint
                        isEditingEndpoint = true
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(endpoint.name)
                                    .font(.headline)
                                
                                Text(endpoint.path)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .onDelete(perform: deleteEndpoint)
                
                Button(action: {
                    currentEndpoint = nil
                    isEditingEndpoint = true
                }) {
                    Label("Add Endpoint", systemImage: "plus")
                }
            }
        }
        .navigationTitle("Custom API Settings")
        .sheet(isPresented: $isEditingEndpoint) {
            APIEndpointEditView(
                endpoint: currentEndpoint,
                onSave: { endpoint in
                    if let index = apiEndpoints.firstIndex(where: { $0.id == endpoint.id }) {
                        apiEndpoints[index] = endpoint
                    } else {
                        apiEndpoints.append(endpoint)
                    }
                }
            )
        }
        .onAppear {
            loadSampleEndpoints()
        }
    }
    
    private func loadSampleEndpoints() {
        apiEndpoints = [
            APIEndpoint(
                id: "1",
                name: "Stock Quote",
                path: "/api/v1/quote",
                method: "GET",
                parameters: [
                    Parameter(name: "symbol", type: .string, required: true),
                    Parameter(name: "fields", type: .string, required: false)
                ]
            ),
            APIEndpoint(
                id: "2",
                name: "Historical Data",
                path: "/api/v1/historical",
                method: "GET",
                parameters: [
                    Parameter(name: "symbol", type: .string, required: true),
                    Parameter(name: "from", type: .date, required: true),
                    Parameter(name: "to", type: .date, required: true),
                    Parameter(name: "interval", type: .string, required: false)
                ]
            )
        ]
    }
    
    private func deleteEndpoint(at offsets: IndexSet) {
        apiEndpoints.remove(atOffsets: offsets)
    }
}

struct APIEndpointEditView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    @State private var path = ""
    @State private var method = "GET"
    @State private var parameters: [Parameter] = []
    
    let methods = ["GET", "POST", "PUT", "DELETE"]
    let onSave: (APIEndpoint) -> Void
    let endpointId: String
    
    init(endpoint: APIEndpoint?, onSave: @escaping (APIEndpoint) -> Void) {
        self.onSave = onSave
        
        if let endpoint = endpoint {
            self._name = State(initialValue: endpoint.name)
            self._path = State(initialValue: endpoint.path)
            self._method = State(initialValue: endpoint.method)
            self._parameters = State(initialValue: endpoint.parameters)
            self.endpointId = endpoint.id
        } else {
            self.endpointId = UUID().uuidString
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Endpoint Details")) {
                    TextField("Name", text: $name)
                    TextField("Path", text: $path)
                    
                    Picker("Method", selection: $method) {
                        ForEach(methods, id: \.self) { method in
                            Text(method).tag(method)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Parameters")) {
                    ForEach(parameters.indices, id: \.self) { index in
                        ParameterRow(parameter: $parameters[index])
                    }
                    .onDelete(perform: deleteParameter)
                    
                    Button(action: addParameter) {
                        Label("Add Parameter", systemImage: "plus")
                    }
                }
            }
            .navigationTitle(name.isEmpty ? "New Endpoint" : name)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    saveEndpoint()
                }
                .disabled(!isValidForm)
            )
        }
    }
    
    private var isValidForm: Bool {
        !name.isEmpty && !path.isEmpty
    }
    
    private func addParameter() {
        parameters.append(Parameter(name: "", type: .string, required: true))
    }
    
    private func deleteParameter(at offsets: IndexSet) {
        parameters.remove(atOffsets: offsets)
    }
    
    private func saveEndpoint() {
        let endpoint = APIEndpoint(
            id: endpointId,
            name: name,
            path: path,
            method: method,
            parameters: parameters
        )
        
        onSave(endpoint)
        presentationMode.wrappedValue.dismiss()
    }
}

struct ParameterRow: View {
    @Binding var parameter: Parameter
    
    let types = ["String", "Number", "Boolean", "Date"]
    
    var body: some View {
        VStack {
            TextField("Name", text: $parameter.name)
            
            HStack {
                Picker("Type", selection: $parameter.type) {
                    Text("String").tag(ParameterType.string)
                    Text("Number").tag(ParameterType.number)
                    Text("Boolean").tag(ParameterType.boolean)
                    Text("Date").tag(ParameterType.date)
                }
                
                Toggle("Required", isOn: $parameter.required)
            }
        }
    }
}

struct AIProviderSettingsView: View {
    @State private var selectedProvider = 0
    @State private var apiKey = ""
    @State private var temperature = 0.7
    @State private var maxTokens = 1000
    @State private var customProviders: [AIProvider] = []
    
    let providers = ["OpenAI", "Claude", "Custom"]
    
    var body: some View {
        Form {
            Section(header: Text("AI Provider")) {
                Picker("Provider", selection: $selectedProvider) {
                    ForEach(0..<providers.count, id: \.self) { index in
                        Text(providers[index]).tag(index)
                    }
                }
                
                if selectedProvider < 2 {
                    TextField("API Key", text: $apiKey)
                        .autocapitalization(.none)
                    
                    HStack {
                        Text("Temperature")
                        Spacer()
                        Text(String(format: "%.1f", temperature))
                    }
                    
                    Slider(value: $temperature, in: 0...1, step: 0.1)
                    
                    HStack {
                        Text("Max Tokens")
                        Spacer()
                        Text("\(maxTokens)")
                    }
                    
                    Slider(value: Binding(
                        get: { Double(maxTokens) },
                        set: { maxTokens = Int($0) }
                    ), in: 100...4000, step: 100)
                }
            }
            
            if selectedProvider == 2 {
                Section(header: Text("Custom Providers")) {
                    ForEach(customProviders) { provider in
                        NavigationLink(destination: CustomProviderDetailView(provider: provider)) {
                            Text(provider.name)
                        }
                    }
                    .onDelete(perform: deleteProvider)
                    
                    NavigationLink(destination: AddCustomProviderView { newProvider in
                        customProviders.append(newProvider)
                    }) {
                        Label("Add Provider", systemImage: "plus")
                    }
                }
            }
            
            Section(header: Text("Chat Settings")) {
                NavigationLink(destination: ChatTemplatesView()) {
                    Text("Manage Chat Templates")
                }
            }
        }
        .navigationTitle("AI Settings")
        .onAppear {
            loadSampleProviders()
        }
    }
    
    private func loadSampleProviders() {
        customProviders = [
            AIProvider(
                id: "1",
                name: "Local LLM",
                baseURL: "http://localhost:8000",
                apiKey: "local_key_123",
                parameters: [
                    "temperature": 0.8,
                    "max_tokens": 2000
                ]
            ),
            AIProvider(
                id: "2",
                name: "Custom Endpoint",
                baseURL: "https://api.example.com/v1",
                apiKey: "custom_key_456",
                parameters: [
                    "temperature": 0.5,
                    "max_tokens": 1500,
                    "presence_penalty": 0.6
                ]
            )
        ]
    }
    
    private func deleteProvider(at offsets: IndexSet) {
        customProviders.remove(atOffsets: offsets)
    }
}

struct CustomProviderDetailView: View {
    let provider: AIProvider
    
    var body: some View {
        Form {
            Section(header: Text("Provider Details")) {
                HStack {
                    Text("Name")
                    Spacer()
                    Text(provider.name)
                }
                
                HStack {
                    Text("Base URL")
                    Spacer()
                    Text(provider.baseURL)
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Text("API Key")
                    Spacer()
                    Text("•••••••••••••••")
                        .foregroundColor(.gray)
                }
            }
            
            Section(header: Text("Parameters")) {
                ForEach(Array(provider.parameters.keys.sorted()), id: \.self) { key in
                    HStack {
                        Text(key)
                        Spacer()
                        if let value = provider.parameters[key] {
                            Text("\(value)")
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
        }
        .navigationTitle(provider.name)
    }
}

struct AddCustomProviderView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    @State private var baseURL = ""
    @State private var apiKey = ""
    @State private var parameters: [String: Double] = [
        "temperature": 0.7,
        "max_tokens": 2000
    ]
    
    let callback: (AIProvider) -> Void
    
    init(callback: @escaping (AIProvider) -> Void) {
        self.callback = callback
    }
    
    var body: some View {
        Form {
            Section(header: Text("Provider Details")) {
                TextField("Name", text: $name)
                TextField("Base URL", text: $baseURL)
                TextField("API Key", text: $apiKey)
            }
            
            Section(header: Text("Parameters")) {
                ForEach(Array(parameters.keys.sorted()), id: \.self) { key in
                    HStack {
                        Text(key)
                        Spacer()
                        TextField("Value", value: Binding(
                            get: { String(parameters[key] ?? 0) },
                            set: { parameters[key] = Double($0) ?? 0 }
                        ))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                    }
                }
                
                Button(action: addParameter) {
                    Label("Add Parameter", systemImage: "plus")
                }
            }
        }
        .navigationTitle("New Provider")
        .navigationBarItems(trailing: Button("Save") {
            saveProvider()
        }
        .disabled(!isValidForm))
    }
    
    private var isValidForm: Bool {
        !name.isEmpty && !baseURL.isEmpty && !apiKey.isEmpty
    }
    
    private func addParameter() {
        // Show an alert or a sheet to add a new parameter
    }
    
    private func saveProvider() {
        let newProvider = AIProvider(
            id: UUID().uuidString,
            name: name,
            baseURL: baseURL,
            apiKey: apiKey,
            parameters: parameters
        )
        
        callback(newProvider)
        presentationMode.wrappedValue.dismiss()
    }
}

struct ChatTemplatesView: View {
    @State private var templates: [ChatTemplate] = []
    
    var body: some View {
        List {
            ForEach(templates) { template in
                VStack(alignment: .leading) {
                    Text(template.name)
                        .font(.headline)
                    
                    Text(template.prompt)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
            }
            .onDelete(perform: deleteTemplate)
            
            NavigationLink(destination: EditTemplateView { newTemplate in
                templates.append(newTemplate)
            }) {
                Label("Add Template", systemImage: "plus")
            }
        }
        .navigationTitle("Chat Templates")
        .onAppear {
            loadSampleTemplates()
        }
    }
    
    private func loadSampleTemplates() {
        templates = [
            ChatTemplate(
                id: "1",
                name: "Stock Analysis",
                prompt: "Analyze the following stock: [SYMBOL]. Consider recent price movements, financial data, and market sentiment."
            ),
            ChatTemplate(
                id: "2",
                name: "Market Overview",
                prompt: "Give me a brief overview of current market conditions. Highlight major index movements, sector performance, and key events."
            ),
            ChatTemplate(
                id: "3",
                name: "Investment Strategy",
                prompt: "Based on my portfolio of [PORTFOLIO], suggest investment strategies for the current market environment."
            )
        ]
    }
    
    private func deleteTemplate(at offsets: IndexSet) {
        templates.remove(atOffsets: offsets)
    }
}

struct EditTemplateView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    @State private var prompt = ""
    
    let callback: (ChatTemplate) -> Void
    
    init(callback: @escaping (ChatTemplate) -> Void) {
        self.callback = callback
    }
    
    var body: some View {
        Form {
            Section(header: Text("Template Details")) {
                TextField("Name", text: $name)
                
                VStack(alignment: .leading) {
                    Text("Prompt Template")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    TextEditor(text: $prompt)
                        .frame(minHeight: 100)
                }
            }
            
            Section(header: Text("Tips")) {
                Text("Use placeholders like [SYMBOL], [DATE], or [PORTFOLIO] that will be replaced when using the template.")
                    .font(.caption)
            }
        }
        .navigationTitle("Edit Template")
        .navigationBarItems(trailing: Button("Save") {
            saveTemplate()
        }
        .disabled(!isValidForm))
    }
    
    private var isValidForm: Bool {
        !name.isEmpty && !prompt.isEmpty
    }
    
    private func saveTemplate() {
        let newTemplate = ChatTemplate(
            id: UUID().uuidString,
            name: name,
            prompt: prompt
        )
        
        callback(newTemplate)
        presentationMode.wrappedValue.dismiss()
    }
}

struct WebContentView: View {
    let urlString: String
    
    var body: some View {
        VStack {
            Text("Web content would be displayed here")
                .foregroundColor(.gray)
        }
    }
}