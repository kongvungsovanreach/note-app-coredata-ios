//
//  ViewController.swift
//  CoreDataHomeworkNote
//
//  Created by Kong Vungsovanreach on 12/8/18.
//  Copyright © 2018 Kong Vungsovanreach. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    //Variable declaration block
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var takeNoteLabel: UILabel!
    @IBOutlet weak var text: UILabel!
    @IBOutlet weak var noteCollectionView: UICollectionView!
    var searchController = UISearchController()
    // Note array for displaying in collectionView
    var notes = [NSManagedObject]()
    // Core data appDelegate and context
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    lazy var context = appDelegate.persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        noteCollectionViewConfigure()
        nibRegisterConfigure()
        bottomBarActionConfigure()
        longCellPressConfigure()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes =
            [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 25)]
        NotificationCenter.default.addObserver(self, selector: #selector(changeLanguage), name: Notification.Name(rawValue: "languageChange"), object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        notes.removeAll()
        fetchNote()
        noteCollectionView.reloadData()
    }

    // Option button tap handler for changing language using localization
    @IBAction func optionButton(_ sender: Any) {
        let alertController = UIAlertController(title: "choose_language".localized, message: "", preferredStyle: .actionSheet)
        // Ipad actionSheet configure
        alertController.popoverPresentationController?.sourceView = self.view
        alertController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection()
        alertController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        //English was chosen
        let en = UIAlertAction(title: "english".localized, style: .default, handler: {(alert) in
            LanguageManagement.shared.language = "en"
            NotificationCenter.default.post(name: Notification.Name("languageChange"), object: nil)
        })
        //Khmer was chosen
        let kh = UIAlertAction(title: "khmer".localized, style: .default, handler:{(alert) in
            LanguageManagement.shared.language = "km"
            NotificationCenter.default.post(name: Notification.Name("languageChange"), object: nil)
        })
        //Korean was chosen
        let kr = UIAlertAction(title: "korean".localized, style: .default, handler: {(alert) in
            LanguageManagement.shared.language = "ko"
            NotificationCenter.default.post(name: Notification.Name("languageChange"), object: nil)
        })
        //Cencel was tapped
        let cancel = UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil)
        alertController.addAction(en)
        alertController.addAction(kh)
        alertController.addAction(kr)
        alertController.addAction(cancel)
        self.present(alertController, animated: true, completion: nil)
    }

    // Function for search button tap
    @IBAction func searchButtonTap(_ sender: Any) {
        searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.barTintColor = UIColor(rgb: 0xFBBC06)
        present(searchController, animated:  true, completion: nil)
    }

    // Function fo fetching the data from Core Data
    func fetchNote() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                notes.append(data)
            }
        } catch {
            print("Failed")
        }
        notes.reverse()
    }

    //Register nib file for custom cell for collectionView
    func nibRegisterConfigure() {
        noteCollectionView.register(UINib(nibName: "CustomCellCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "reusableCell")
    }

    // Bottom bar label handler for inserting a new note
    func bottomBarActionConfigure() {
        iconLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addNewNote)))
        takeNoteLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addNewNote)))
    }

    // Configure collectionView datasource and delegate
    func noteCollectionViewConfigure() {
        noteCollectionView.dataSource = self
        noteCollectionView.delegate = self
    }

    // Hangler function for longpress to delete the item of collectionView
    @objc func handleLongPress(_ gestureRecognizer : UILongPressGestureRecognizer){
        if (gestureRecognizer.state != UIGestureRecognizer.State.began){
            return
        }
        let cellLocation = gestureRecognizer.location(in: noteCollectionView)
        if let index : IndexPath = (noteCollectionView.indexPathForItem(at: cellLocation)){
            let alertController = UIAlertController(title: "wanna_delete".localized, message: "", preferredStyle: .actionSheet)
            // Actionsheet alert for ipad configure
            alertController.popoverPresentationController?.sourceView = self.view
            alertController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection()
            alertController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            let agree = UIAlertAction(title: "delete_one".localized, style: .default) { (alert) in
                self.deleteObject(self.notes[index.row])
                self.notes.remove(at: index.row)
                self.noteCollectionView.deleteItems(at: [index])

            }
            let agreeAll = UIAlertAction(title: "delete_all".localized, style: .default) { (alert) in
                self.deleteAllCoreData()
                self.notes.removeAll()
                self.noteCollectionView.reloadData()

            }
            let deny = UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil)
            alertController.addAction(agree)
            alertController.addAction(agreeAll)
            alertController.addAction(deny)
            self.present(alertController, animated: true, completion: nil)
        }
    }

    // Add new note handler
    @objc func addNewNote() {
        self.performSegue(withIdentifier: "detail", sender: self)
    }

    // Change language
    @objc func changeLanguage(){
        takeNoteLabel.text = "takeNote".localized
        self.navigationItem.title = "title".localized
        searchController.searchBar.placeholder = "search".localized
    }
}

// Configure collectionView item and item click handler
extension ViewController : UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return notes.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reusableCell = collectionView.dequeueReusableCell(withReuseIdentifier: "reusableCell", for: indexPath) as! CustomCellCollectionViewCell
        reusableCell.titleLabel.text = (notes[indexPath.row].value(forKey: "title") as! String)
        reusableCell.contentLabel.text = (notes[indexPath.row].value(forKey: "content") as! String)
        return reusableCell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        NoteDetailViewController.note = notes[indexPath.row]
        self.performSegue(withIdentifier: "detail", sender: self)
    }
    // Responsive item layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = collectionView.frame.size.width - 10
        let orientation = UIApplication.shared.statusBarOrientation
        if(orientation == .landscapeLeft || orientation == .landscapeRight)
        {
            return CGSize(width: w/3, height: w / 3)
        }
        else{
            return CGSize(width: w/2, height: w / 2)
        }
    }

    // Delete object from Core Data
    func deleteObject(_ object : NSManagedObject) {
        context.delete(object)
        do{
            try? context.save()
        }
    }
}

extension ViewController : UIGestureRecognizerDelegate {
    // Longpress configure to delet item
    func longCellPressConfigure() {
        let longPress : UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPress.minimumPressDuration = 0.5
        longPress.delegate = self
        longPress.delaysTouchesBegan = true
        noteCollectionView.addGestureRecognizer(longPress)
    }

    // Delete all data from CoreData
    func deleteAllCoreData()  {
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print ("There was an error")
        }
    }
}
