/// Copyright (c) 2020 Amr Elsayed
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Alamofire

class MonstersTableViewController: UITableViewController {
  @IBOutlet weak var searchBar: UISearchBar!
  var items: [DndResource] = []
  var selectedItem: DndResource?
  var monsters: [DndResource] = [] {
    didSet {
      items = monsters
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    fetchMonsters()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard
      let imagesCollectionViewController = segue.destination as? ImagesCollectionViewController,
      let selectedItemName = selectedItem?.name
      else {
        return
    }
    imagesCollectionViewController.query = selectedItemName
  }
}

// MARK: - UITableViewDataSource
extension MonstersTableViewController {
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "dataCell", for: indexPath)
    let item = items[indexPath.row]
    cell.textLabel?.text = item.name
    return cell
  }
}

// MARK: - UITableViewDelegate
extension MonstersTableViewController {
  override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    selectedItem = items[indexPath.row]
    return indexPath
  }
}

// MARK: - UISearchBarDelegate
extension MonstersTableViewController: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    guard let equipmentName = searchBar.text else { return }
    searchEquipment(with: equipmentName)
  }
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.text = nil
    searchBar.resignFirstResponder()
    items = monsters
    tableView.reloadData()
  }
}

// MARK: - Alamofire
extension MonstersTableViewController {
  func fetchMonsters() {
    AF.request("https://www.dnd5eapi.co/api/monsters")
      .validate()
      .responseDecodable(of: DndResources.self) { (response) in
        guard let monsters = response.value else { return }
        self.monsters = monsters.all
        self.tableView.reloadData()
    }
  }
  
  func searchEquipment(with name: String) {
    AF.request("https://www.dnd5eapi.co/api/equipment",parameters: ["name": name])
      .validate()
      .responseDecodable(of: DndResources.self) { response in
        guard let equipment = response.value else { return }
        self.items = equipment.all
        self.tableView.reloadData()
    }
  }
}

// MARK: - Network Reachability
