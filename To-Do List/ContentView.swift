//
//  ContentView.swift
//  To-Do List
//
//  Created by Łukasz Janiszewski on 17/07/2021.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @AppStorage("isDarkMode") private var darkMode = false

    @FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Item.title, ascending: true)],
            animation: .default)
    private var items: FetchedResults<Item>

    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            VStack {
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 25)
                            .foregroundColor(darkMode == true ? .white : .black)
                            .frame(width: screenWidth * 0.55, height: screenHeight * 0.08)
                        
                        Text("To-Do List 📝")
                            .font(.largeTitle)
                            .foregroundColor(darkMode == true ? .black : .white)
                    }
                    .padding(.leading, screenWidth * 0.05)
                    
                    Spacer()
                    
                    Toggle("", isOn: $darkMode)
                        .toggleStyle(SwitchToggleStyle(tint: .clear))
                        .frame(width: screenWidth * 0.15)
                        .padding(.trailing, screenWidth * 0.1)
                }
                
                NavigationView {
                    VStack {
                        List {
                            ForEach(items) { item in
                                    VStack {
                                        NavigationLink(destination: DetailView(item: item)) {
                                            Text("\(item.title!)")
                                                .font(.system(size: screenWidth * 0.05))
                                        }
                                    }
                                    .navigationTitle("Monday")
                                }
                            .onDelete(perform: deleteItems)
                        }
                        .frame(width: screenWidth, height: screenHeight)
                    }
                    .padding(.bottom, -screenHeight * 0.3)
                }
                  
                ZStack {
                    RoundedRectangle(cornerRadius: 25, style: .continuous)
                        .fill(Color.blue)
                        .frame(width: screenWidth * 0.3, height: screenHeight * 0.05)
                    
                    Button(action: addItem) {
                        Label("Add Task", systemImage: "plus")
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.top, screenHeight * 0.025)
            .preferredColorScheme(darkMode ? .dark : .light)
            .environment(\.colorScheme, darkMode ? .dark : .light)
        }
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.title = "newItem"
            newItem.fullDescription = "description"
            newItem.day = "Monday"
            newItem.finished = false

            saveContext()
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            saveContext()
        }
    }
}

struct DetailView: View {
    private var item: Item
    
    @State private var itemTitle = ""
    @State private var itemDescription = ""
    @State private var itemDay = ""
    @State private var itemDate = Date()
    @State private var itemFinished = false
    
    init(item: Item) {
        self.item = item
        self.itemTitle = self.item.title!
        self.itemDescription = self.item.fullDescription!
        self.itemDay = self.item.day!
        self.itemDate = self.item.date!
        self.itemFinished = self.item.finished
    }
    
    let dateRange: ClosedRange<Date> = {
        let calendar = Calendar.current
        let startComponents = DateComponents(year: 2021, month: 1, day: 1)
        let endComponents = DateComponents(year: 2021, month: 12, day: 31, hour: 23, minute: 59, second: 59)
        return calendar.date(from:startComponents)!
            ...
            calendar.date(from:endComponents)!
    }()
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            VStack (spacing: screenHeight * 0.05) {
                Section(header: Text("TITLE")) {
                    TextField(self.item.title!, text: $itemTitle)
                        .padding(.leading, screenWidth * 0.05)
                }
                
                Section(header: Text("DESCRIPTION")) {
                    TextField(self.item.fullDescription!, text: $itemDescription)
                        .padding(.leading, screenWidth * 0.05)
                        
                }
                
                Section(header: Text("DAY")) {
                    TextField(self.item.day!, text: $itemDay)
                        .padding(.leading, screenWidth * 0.05)
                }
                
                Section(header: Text("DATE")) {
                    DatePicker("", selection: $itemDate, in: dateRange, displayedComponents: [.date, .hourAndMinute])
                        .padding(.trailing, screenWidth * 0.28)
                        
                }
                
                Section(header: Text("FINISHED")) {
                    Toggle("", isOn: $itemFinished)
                        .padding(.trailing, screenWidth * 0.45)
                }
                
                ZStack {
                    RoundedRectangle(cornerRadius: 25, style: .continuous)
                        .fill(Color.green)
                        .frame(width: screenWidth * 0.35, height: screenHeight * 0.07)
                    
                    Button(action: {
                        if !self.itemTitle.isEmpty {
                            self.item.title = self.itemTitle
                        }
                        if !self.itemDescription.isEmpty {
                            self.item.fullDescription = self.itemDescription
                        }
                        if !self.itemDay.isEmpty {
                            self.item.day = self.itemDay
                        }
                        self.item.date = self.itemDate
                        self.item.finished = self.itemFinished
                    }) {
                        Label("Save changes", systemImage: "")
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}


