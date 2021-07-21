//
//  ContentView.swift
//  To-Do List
//
//  Created by Łukasz Janiszewski on 17/07/2021.
//

import SwiftUI
import CoreData

let daysOfTheWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @AppStorage("isDarkMode") private var darkMode = false
    @State var showAddFormView = false

    @FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Item.title, ascending: true)],
            animation: .default)
    private var items: FetchedResults<Item>

    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            if showAddFormView {
                AddTaskView()
            } else {
                VStack {
                    TopView()
                        .frame(width: screenWidth, height: screenHeight * 0.1)
                        .padding(.top, screenHeight * 0.025)
                    
                    NavigationView {
                        VStack {
                            List {
                                ForEach(items) { item in
                                    NavigationLink(destination: DetailView(newItem: item)) {
                                        HStack {
                                            Text("\(item.title!)")
                                                .font(.system(size: screenWidth * 0.05))
                                                .frame(width: screenWidth * 0.6, height: screenHeight * 0.04, alignment: .leading)
                                            
                                            if item.finished == true {
                                                Circle().foregroundColor(.green)
                                            } else {
                                                Circle().foregroundColor(.red)
                                            }
                                        }
                                    }
                                }
                                .onDelete(perform: deleteItems)
                            }
                        }
                        .navigationBarHidden(true)
                    }
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 25, style: .continuous)
                            .fill(Color.blue)
                            .frame(width: screenWidth * 0.3, height: screenHeight * 0.05)
                        
                        Button(action: { showAddFormView = true }) {
                            Label("Add Task", systemImage: "plus")
                                .foregroundColor(.white)
                        }
                    }
                }
                .preferredColorScheme(darkMode ? .dark : .light)
                .environment(\.colorScheme, darkMode ? .dark : .light)
            }
        }
    }
    
    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.title = "newItem"
            newItem.fullDescription = "description"
            newItem.day = getDayOfTheWeekFromDate(passedDate: Date())
            newItem.date = Date()
            newItem.finished = false

            saveContext()
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
    
//    private func divideItemsAccordingToTheirDays(items: [Item]) -> [[Item]] {
//        var itemsInDays: [[Item]] = [[], [], [], [], [], [], []]
//
//        ForEach(items, id: \.self) { item in
//            if item.day! == "Monday" {
//                itemsInDays[] = item
//            }
//        }
//    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            saveContext()
        }
    }
}

struct AddTaskView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @AppStorage("isDarkMode") private var darkMode = false
    @State var showTaskView = false
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            VStack {
                if showTaskView {
                    withAnimation {
                        ContentView()
                    }
                } else {
                    
                    TopView()
                        .frame(width: screenWidth, height: screenHeight * 0.1)
                        .padding(.top, screenHeight * 0.025)
    //
    //                VStack (spacing: screenHeight * 0.04) {
    //                    Section(header: Text("TITLE")) {
    //                        TextField(self.item.title!, text: $item.title ?? "")
    //                            .padding(.horizontal, screenWidth * 0.05)
    //                    }
    //
    //                    Section(header: Text("DESCRIPTION")) {
    //                        TextField(self.item.fullDescription!, text: $item.fullDescription ?? "")
    //                            .padding(.horizontal, screenWidth * 0.05)
    //                    }
    //
    //                    Section(header: Text("DAY")) {
    //                        Text(self.item.day!)
    //                            .foregroundColor(.blue)
    //                    }
    //
    //                    Section(header: Text("DATE")) {
    //                        DatePicker("", selection: $item.date ?? Date(), in: dateRange, displayedComponents: [.date])
    //                            .padding(.trailing, screenWidth * 0.37)
    //                    }
    //
    //                    Section(header: Text("FINISHED")) {
    //                        Toggle("", isOn: $item.finished)
    //                            .padding(.trailing, screenWidth * 0.45)
    //                    }
    //                }
    //                .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 25, style: .continuous)
                            .fill(Color.red)
                            .frame(width: screenWidth * 0.3, height: screenHeight * 0.05)
                        
                        Button(action: { showTaskView = true }) {
                            Label("Save Task", systemImage: "")
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .preferredColorScheme(darkMode ? .dark : .light)
            .environment(\.colorScheme, darkMode ? .dark : .light)
        }
    }
}

struct DetailView: View {
    @State private var item: Item
    
    init(newItem: Item) {
        _item = State(initialValue: newItem)
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
            
            VStack (spacing: screenHeight * 0.04) {
                Section(header: Text("TITLE")) {
                    TextField(self.item.title!, text: $item.title ?? "")
                        .padding(.horizontal, screenWidth * 0.05)
                }
                
                Section(header: Text("DESCRIPTION")) {
                    TextField(self.item.fullDescription!, text: $item.fullDescription ?? "")
                        .padding(.horizontal, screenWidth * 0.05)
                }
                
                Section(header: Text("DAY")) {
                    Text(self.item.day!)
                        .foregroundColor(.blue)
                }
                
                Section(header: Text("DATE")) {
                    DatePicker("", selection: $item.date ?? Date(), in: dateRange, displayedComponents: [.date])
                        .padding(.trailing, screenWidth * 0.37)
                }
                
                Section(header: Text("FINISHED")) {
                    Toggle("", isOn: $item.finished)
                        .padding(.trailing, screenWidth * 0.45)
                }
            }
            .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
    
}

struct TopView: View {
    @AppStorage("isDarkMode") private var darkMode = false
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 25)
                        .foregroundColor(darkMode == true ? .white : .black)
                        .frame(width: screenWidth * 0.55, height: screenHeight * 0.75)
                    
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
        }
    }
}

public func ??<T>(lhs: Binding<Optional<T>>, rhs: T) -> Binding<T> {
    Binding(
        get: { lhs.wrappedValue ?? rhs },
        set: { lhs.wrappedValue = $0 }
    )
}

public func getDayOfTheWeekFromDate(passedDate: Date) -> String {
    let date = passedDate
    let calendar = Calendar.current
    let components = calendar.dateComponents([.weekday], from: date)
    let numberOfDayOfWeek = components.weekday
    var dayOfWeek: String
    
    switch numberOfDayOfWeek {
    case 1:
        dayOfWeek = "Sunday"
    case 2:
        dayOfWeek = "Monday"
    case 3:
        dayOfWeek = "Tuesday"
    case 4:
        dayOfWeek = "Wednesday"
    case 5:
        dayOfWeek = "Thursday"
    case 6:
        dayOfWeek = "Friday"
    case 7:
        dayOfWeek = "Saturday"
    default:
        dayOfWeek = ""
    }
    
    return dayOfWeek
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}


