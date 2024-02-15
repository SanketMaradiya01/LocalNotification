//
//  ReminderVC.swift
//  LocalNotification
//
//  Created by Nimap on 15/02/24.
//

import UIKit

protocol DetailPass : AnyObject {
    func PassingData (Time : Date)
}

class ReminderVC: UIViewController {

    var DatePicker : UIDatePicker!
    var TopBar : UIView!
    var TopLabel : UILabel!
    var saveBtn : UIButton!
    
    var delegate : DetailPass?
    
    var appdelegate = UIApplication.shared.delegate as! AppDelegate
    
    var Data = [LocalNotification](){
        didSet{}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SetUI()
    }
    func SetUI(){
        
        view.backgroundColor = .white
       
        TopBar = UIView()
        TopBar.backgroundColor = .gray
        view.addSubview(TopBar)
        TopBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            TopBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            TopBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            TopBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            TopBar.heightAnchor.constraint(equalToConstant: 50.0)
        ])
        
        TopLabel = UILabel()
        TopLabel.text = "Local Notification"
        TopLabel.textAlignment = .center
        TopLabel.font = UIFont.boldSystemFont(ofSize: 18.0)
        TopLabel.textColor = .white
        TopBar.addSubview(TopLabel)
        TopLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            TopLabel.topAnchor.constraint(equalTo: TopBar.topAnchor),
            TopLabel.leadingAnchor.constraint(equalTo: TopBar.leadingAnchor),
            TopLabel.trailingAnchor.constraint(equalTo: TopBar.trailingAnchor),
            TopLabel.bottomAnchor.constraint(equalTo: TopBar.bottomAnchor)
        ])
        
        saveBtn = UIButton(type: .system)
        saveBtn.frame = CGRect(x: 50, y: 100, width: 150, height: 50)
        saveBtn.setTitle("Save", for: .normal)
        saveBtn.setTitleColor(.white, for: .normal)
        saveBtn.addTarget(self, action: #selector(SaveBtn), for: .touchUpInside)
        TopBar.addSubview(saveBtn)
        saveBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            saveBtn.centerYAnchor.constraint(equalTo: TopBar.centerYAnchor),
            saveBtn.trailingAnchor.constraint(equalTo: TopBar.trailingAnchor, constant: -4.0)
        ])
        
        DatePicker = UIDatePicker()
        DatePicker.datePickerMode = .dateAndTime
        DatePicker.preferredDatePickerStyle = .wheels
        view.addSubview(DatePicker)
        DatePicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            DatePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            DatePicker.centerYAnchor.constraint(equalTo: view.centerYAnchor)
       ])
    }
    @objc func SaveBtn() {
        let targetDate = DatePicker.date
            delegate?.PassingData(Time: targetDate)
            navigationController?.popViewController(animated: true)
    }
}
