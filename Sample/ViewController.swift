//
//  ViewController.swift
//  Sample
//
//  Created by KOSURU UDAY SAIKUMAR on 14/10/21.
//

import UIKit


typealias Selectable = Equatable & CustomStringConvertible

class ViewController<A: Selectable>: UITableViewController {
    
    var dataSource: [A] = []
    var alreadySelectedData: [A]?
    var isMultipleSelectionEnabled: Bool = false
    
    var selectAllButton: UIBarButtonItem?
    
    var onSelection: (([A]) -> Void)?
    
    init?(dataSource: [A], isMultiSelectionEnabled enabled: Bool, style: UITableView.Style) {
        guard dataSource.count > 0 else { return nil }
        self.dataSource = dataSource
        self.isMultipleSelectionEnabled = enabled
        super.init(style: style)
        self.tableView.allowsMultipleSelection = enabled
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(SelectionTableCell.self, forCellReuseIdentifier: "cellId")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupBarItems()
        setupForAlreadySelectedData()
    }
    
    private func setupBarItems() {
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction))
        self.navigationItem.rightBarButtonItem = doneButton
        
        guard isMultipleSelectionEnabled else { return }
        
        self.selectAllButton = UIBarButtonItem(title: "Select All", style: UIBarButtonItem.Style.plain, target: self, action: #selector(selectAllAction))
        self.navigationController?.setToolbarHidden(false, animated: true)
        self.toolbarItems = [selectAllButton!]
    }
    
    @objc func doneAction() {
        var selectedItems = [A]()
        if let indexPaths = self.tableView.indexPathsForSelectedRows {
            for item in indexPaths {
                selectedItems.append(dataSource[item.row])
            }
        }
        onSelection?(selectedItems)
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func selectAllAction() {
        let indexPaths = (0..<dataSource.count).map{IndexPath(row: $0, section: 0)}
        if isAllSelected {
            for indexPath in indexPaths {
                self.tableView.deselectRow(at: indexPath, animated: true)
            }
        }else {
            for indexPath in indexPaths {
                self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableView.ScrollPosition.none)
            }
        }
        updateSelectAllButton()
    }
    
    fileprivate func setupForAlreadySelectedData() {
        guard let alreadySelectedData = self.alreadySelectedData else { return }
        let indexPaths = dataSource.indeces(from: alreadySelectedData).map({IndexPath(row: $0, section: 0)})
        for indexPath in indexPaths {
            self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.none)
        }
        updateSelectAllButton()
    }
    
    fileprivate var isAllSelected: Bool {
        let selectedItems = self.tableView.indexPathsForSelectedRows
        return selectedItems?.count == self.dataSource.count
    }
    
    fileprivate func updateSelectAllButton() {
        selectAllButton?.title = isAllSelected ? "Deselect All" : "Select All"
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        let data = dataSource[indexPath.row]
        cell.textLabel?.text = data.description
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        updateSelectAllButton()
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        updateSelectAllButton()
    }
    
}


class SelectionTableCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.accessoryType = selected ? .checkmark : .none
    }
    
}
