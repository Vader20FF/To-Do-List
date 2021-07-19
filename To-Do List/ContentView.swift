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
                                        NavigationLink(destination: DetailView()) {
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
                        Label("Add Item", systemImage: "plus")
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

struct EditView: View {
    var body: some View {
        GeometryReader { geometry in
//            let screenWidth = geometry.size.width
//            let screenHeight = geometry.size.height
        }
    }
}

struct DetailView: View {
    var body: some View {
        GeometryReader { geometry in
//            let screenWidth = geometry.size.width
//            let screenHeight = geometry.size.height
            
            Text("LOL")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}


