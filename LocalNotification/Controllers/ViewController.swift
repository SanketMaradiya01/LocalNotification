//
//  ViewController.swift
//  LocalNotification
//
//  Created by Nimap on 15/02/24.
//

import UIKit

class ViewController: UIViewController,DetailPass {
    
    
    
    var TopView : UIView!
    var TitleLabel : UILabel!
    var tableView : UITableView!
    var AddBtn : UIButton!
    
    var NotificationDataArray = [LocalNotification]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
        UI()
        tableView.reloadData()
    }
    func UI(){
        TopView = UIView()
        TopView.backgroundColor = .gray
        view.addSubview(TopView)
        TopView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            TopView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            TopView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            TopView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            TopView.heightAnchor.constraint(equalToConstant: 50.0)
        ])
        
        TitleLabel = UILabel()
        TitleLabel.text = "Local Notification"
        TitleLabel.textAlignment = .center
        TitleLabel.font = UIFont.boldSystemFont(ofSize: 18.0)
        TitleLabel.textColor = .white
        TopView.addSubview(TitleLabel)
        TitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            TitleLabel.topAnchor.constraint(equalTo: TopView.topAnchor),
            TitleLabel.leadingAnchor.constraint(equalTo: TopView.leadingAnchor),
            TitleLabel.trailingAnchor.constraint(equalTo: TopView.trailingAnchor),
            TitleLabel.bottomAnchor.constraint(equalTo: TopView.bottomAnchor)
        ])
        
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: TopView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        AddBtn = UIButton(type: .system)
        AddBtn.frame = CGRect(x: 50, y: 100, width: 150, height: 50)
        AddBtn.setTitle("Add", for: .normal)
        AddBtn.setTitleColor(.white, for: .normal)
        AddBtn.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        TopView.addSubview(AddBtn)
        AddBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            AddBtn.centerYAnchor.constraint(equalTo: TopView.centerYAnchor),
            AddBtn.trailingAnchor.constraint(equalTo: TopView.trailingAnchor, constant: -4.0)
        ])
    }
    @objc func buttonPressed() {
        let vc = ReminderVC()
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func PassingData(Time: Date) {
        saveToCoreData(time: Time)
        fetchData()
    }
    func saveToCoreData(time: Date) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("Error: Unable to access app delegate")
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        
        // Create a new instance of ReminderData
        let reminderData = LocalNotification(context: context)
        reminderData.time = time // Set the time
        
        // Save the context
        do {
            try context.save()
            // Append the saved ReminderData to the array
            if !NotificationDataArray.contains(where: { $0.time == time }) {
                NotificationDataArray.append(reminderData)
            }
            // Reload the table view to reflect the changes
            tableView.reloadData()
            // Schedule local notification
            scheduleLocalNotification(for: time)
        } catch {
            print("Error saving reminder data: \(error.localizedDescription)")
        }
    }
    func scheduleLocalNotification(for time: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.sound = .default
        content.body = "Notification Received"
        
        let calendar = Calendar.current
        var components = calendar.dateComponents([.hour, .minute], from: time)
        components.timeZone = TimeZone.current
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let identifier = "ReminderNotification_\(time.timeIntervalSince1970)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Notification scheduled successfully with identifier: \(identifier)")
            }
        }
    }
    func fetchData() {
        NotificationDataArray = [] 
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        
        do {
            // Fetch all ReminderData objects from Core Data
            NotificationDataArray = try context.fetch(LocalNotification.fetchRequest())
            
            // Reload table view on the main thread after fetching data
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            print("Error fetching reminders: \(error.localizedDescription)")
        }
    }
}
extension ViewController : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return NotificationDataArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if indexPath.row < NotificationDataArray.count {
            let NotificationData = NotificationDataArray[indexPath.row]
            if let time = NotificationData.time {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm a"
                let formattedTime = dateFormatter.string(from: time)
                cell.textLabel!.text = formattedTime
            } else {
                cell.textLabel!.text = "No time available"
            }
        } else {
            // Handle the case when the index is out of bounds
            cell.textLabel!.text = "Invalid index"
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                let reminderData = NotificationDataArray.remove(at: indexPath.row)
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    let context = appDelegate.persistentContainer.viewContext
                    context.delete(reminderData)
                    do {
                        try context.save()
                    } catch {
                        print("Error saving context after deleting reminder: \(error)")
                    }
                }
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
}

