//
//  ViewController.swift
//  SampleTodo
//
//  Created by prautela on 30/07/24.
//

import UIKit

protocol TodoView: AnyObject {
    func insetTodoItem() -> ()
    func removeTodoItem(at index:Int) -> ()
    func updataTodoItem(at index:Int) -> ()
    func reloadItems() -> ()
    func reset() -> ()
}

class ViewController: UIViewController {

    @IBOutlet weak var todoTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: TodoViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = TodoViewModel(view: self,database: RealtimeDatabase.shared)
        viewModel?.isRealTime = true
    }
    
}

extension ViewController {
    
    @IBAction func addTodoAction(_ sender: Any) {
        
        guard let newValue = todoTextField.text, newValue.isEmpty == false else { return }
        viewModel?.newTodoItem = newValue
        
        DispatchQueue.global(qos: .background).async { [viewModel] in
            viewModel?.onAddTodoItem()
        }
        
    }
}

extension ViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.items.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemTableViewCell", for: indexPath) as! TodoItemTableViewCell
        
        let model = viewModel?.items[indexPath.row]
        cell.todoLabel.text = model?.name
        
        cell.todoUpdateActionButton.tag = indexPath.row
        cell.deleteActionButton.tag = indexPath.row
        
        cell.todoUpdateActionButton.addTarget(self, action: #selector(doneAction), for: .touchUpInside)
        cell.deleteActionButton.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
        
        cell.todoLabel.textColor = model?.completed ?? false ? UIColor.red : UIColor.black
        
        return cell
    }
    
    @objc func doneAction(_ sender:UIButton) {
        let item = viewModel?.items[sender.tag]
        viewModel?.onDone(todoId: item?.id ?? "")
    }
    
    @objc func deleteAction(_ sender:UIButton) {
        let item = viewModel?.items[sender.tag]
        viewModel?.onDelete(todoId: item?.id ?? "")
    }
    
}

extension ViewController: TodoView {
    
    func insetTodoItem() {
        
    }
    
    func removeTodoItem(at index: Int) {
        
    }
    
    func updataTodoItem(at index: Int) {
        
    }
    
    func reloadItems() {
        self.tableView.reloadData()
    }
    
    func reset() {
        todoTextField.text = ""
    }
    
}
