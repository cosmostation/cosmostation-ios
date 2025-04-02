//
//  DappListViewController.swift
//  Cosmostation
//
//  Created by 차소민 on 2/14/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import UIKit
import SwiftUI
import Combine
import SwiftyJSON

class DappListViewController: BaseVC {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var sortButton: UIButton!
    
    @IBOutlet weak var selectNetworkView: UIStackView!
    @IBOutlet weak var networkImageView: UIImageView!
    @IBOutlet weak var networkLabel: UILabel!
    
    @IBOutlet weak var pinnedFilterButton: UIButton!
    
    @IBOutlet weak var typeScrollView: UIScrollView!
    @IBOutlet weak var typeStackView: UIStackView!
    @IBOutlet weak var collectionView: UICollectionView!
    var typeButtons: [UIButton] = []
    
    var allEcosystems = [JSON()]
    var displayEcosystems = [JSON()]
    var types = ["Popular","All"]
    var selectedType = "Popular"
    var selectedNetwork: BaseChain? = nil
    
    let favoriteModel = DappFavoriteModel()
    let dappDetailVCStateModel = DappDetailVCState()
    var cancellables = Set<AnyCancellable>()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //data setting
        baseAccount = BaseData.instance.baseAccount
        allEcosystems = BaseData.instance.allEcosystems ?? []
        
        let rawValue = UserDefaults.standard.integer(forKey: KEY_DAPP_SORT_OPTION)
        switch DappSortType(rawValue: rawValue) ?? .alphabet {
        case .alphabet :
            self.allEcosystems.sort {
                $0["name"].stringValue < $1["name"].stringValue
            }
        case .networks:
            self.allEcosystems.sort {
                $0["chains"].arrayValue.count > $1["chains"].arrayValue.count
            }
        }
        
        let type = Set(allEcosystems.map({ $0["type"].stringValue }))
        types += type.sorted()
        
        displayEcosystems = allEcosystems.filter({ $0["is_default"].boolValue == true })
        
        //collectionView
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "AllDappListCell", bundle: nil), forCellWithReuseIdentifier: "AllDappListCell")
        
        //select network button
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onBindSelectNetworkSheet))
        selectNetworkView.addGestureRecognizer(tapGesture)
        setNetworkUI()
        
        //favorite button
        pinnedFilterButton.configuration?.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        pinnedFilterButton.configurationUpdateHandler = { button in
            button.configuration?.image = button.isSelected ? UIImage(named: "iconCheckboxOn"): UIImage(named: "iconCheckboxOff")
        }

        //search bar
        searchBar.clipsToBounds = true
        searchBar.layer.cornerRadius = 6
        searchBar.searchTextField.font = .fontSize12Medium
        searchBar.placeholder = "Search Dapp"
        searchBar.delegate = self
        
        let keyboardDismissGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        keyboardDismissGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(keyboardDismissGesture)
        
        //sort button
        sortButton.clipsToBounds = true
        sortButton.layer.cornerRadius = 6
        sortButton.layer.borderWidth = 1
        sortButton.layer.borderColor = UIColor.color07.cgColor
        
        // type button
        for (index, title) in types.enumerated() {
            let button = createTypeButton(title: title, index: index)
            typeButtons.append(button)
            button.tag = index
            button.addTarget(self, action: #selector(typeButtonTapped), for: .touchUpInside)
            typeStackView.addArrangedSubview(button)
            button.configurationUpdateHandler = { button in
                if button.isSelected {
                    button.configuration?.baseBackgroundColor = .color05
                    button.configuration?.baseForegroundColor = .color01
                } else {
                    button.configuration?.baseBackgroundColor = .clear
                    button.configuration?.baseForegroundColor = .color04
                }
            }
        }
        
        // data binding
        favoriteModel.$favorites
            .sink { favorites in
                let cells = self.collectionView.visibleCells
                cells.forEach {
                    if let cell = $0 as? AllDappListCell, let id = cell.id {
                        cell.updateFavoriteButton(favorites.contains(id) ? true : false)
                    }
                }
            }
            .store(in: &cancellables)
        
        dappDetailVCStateModel.$shouldPresentVC
            .sink { shouldPresent in
                if shouldPresent {
                    let dappDetail = DappDetailVC(nibName: "DappDetailVC", bundle: nil)
                    dappDetail.dappType = .INTERNAL_URL
                    dappDetail.dappUrl = URL(string: self.dappDetailVCStateModel.link)
                    dappDetail.targetChain = self.selectedNetwork
                    print("TEST", self.selectedNetwork)
                    dappDetail.modalPresentationStyle = .fullScreen
                    self.present(dappDetail, animated: false)
                }
            }
            .store(in: &cancellables)
    }
    
    func setNetworkUI(_ chain: BaseChain? = nil) {
        if let chain {
            networkLabel.text = chain.name
            networkImageView.image = UIImage(named: chain.logo1)
            
        } else {
            networkLabel.text = "All Network"
            networkImageView.image = UIImage(named: "iconNetwork")
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func onBindSelectNetworkSheet() {
        Task {
            var network = [DappNetwork(chain: nil, dappCount: allEcosystems.count)]
            let allChains = await baseAccount.initAllKeys().filter { $0.isDefault }
            
            let sheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
            sheet.sheetDelegate = self
            sheet.sheetType = .SelectDappNetwork
            allChains.filter({ !$0.isTestnet }).forEach { chain in
                let count = allEcosystems.filter({ ecosystem in
                    ecosystem["chains"].arrayValue.map({$0.stringValue}).contains(chain.apiName)
                }).count
                network.append(DappNetwork(chain: chain, dappCount: count))
            }
            sheet.dappNetworks = network
            sheet.dappSelectedNetwork = allChains.filter({ $0.name == networkLabel.text }).first
            
            DispatchQueue.main.async {
                self.present(sheet, animated: true)
            }
        }
    }
    
    
    @IBAction func sortButtonTapped(_ sender: Any) {
        let sortRawValue = UserDefaults.standard.integer(forKey: KEY_DAPP_SORT_OPTION)
        
        let sheet = BaseSheet(nibName: "BaseSheet", bundle: nil)
        sheet.sheetDelegate = self
        sheet.selectedDappSortType = DappSortType(rawValue: sortRawValue)
        sheet.sheetType = .SelectDappSort
        onStartSheet(sheet, 320, 0.6)
    }
    
    @objc func typeButtonTapped(_ button: UIButton) {
        
        button.isSelected = true
        typeButtons.filter({ $0 != button }).forEach { $0.isSelected = false }
        
        let point = CGPoint(
            x: button.frame.origin.x - (typeScrollView.frame.width - button.frame.size.width) / 2,
            y: button.frame.origin.y - (typeScrollView.frame.height - button.frame.size.height) / 2
        )
        let size = typeScrollView.frame.size
        let rect = CGRect(origin: point, size: size)
        typeScrollView.scrollRectToVisible(rect, animated: true)
        
        guard let type = button.configuration?.title else { return }
        self.selectedType = type
        
        updateCollectionView(type, pinnedFilterButton.isSelected, selectedNetwork)
    }
    
    
    private func createTypeButton(title: String, index: Int) -> UIButton {
        let button = UIButton()
        
        var config = UIButton.Configuration.filled()
        
        config.cornerStyle = .capsule
        config.baseForegroundColor = .white
        config.title = title
        config.attributedTitle?.font = UIFont.fontSize11Bold
        
        if index == 0 {
            button.isSelected = true
            config.baseBackgroundColor = .color05
            config.baseForegroundColor = .color01
            config.image = UIImage(named: "iconPopular")
            config.imagePadding = 3
        } else {
            config.baseBackgroundColor = .clear
            config.baseForegroundColor = .color04
        }
        button.configuration = config
        
        return button
    }
    
    @IBAction func pinnedFilterButtonTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        updateCollectionView(selectedType, sender.isSelected, selectedNetwork)
    }

    
    func updateCollectionView(_ type: String, _ pinned: Bool, _ chain: BaseChain? = nil) {
        
        if type == "Popular" {
            displayEcosystems = allEcosystems.filter {
                let type = $0["is_default"].boolValue
                let chain = chain == nil || $0["chains"].arrayValue.map({$0.stringValue}).contains(chain?.apiName)
                let pinned = pinned ? favoriteModel.isFavorite(id: $0["id"].intValue) : true
                let search = searchBar.text!.isEmpty || $0["name"].stringValue.range(of: searchBar.text ?? "", options: .caseInsensitive, range: nil, locale: nil) != nil
                return type && chain && pinned && search
            }

        } else if type == "All" {
            displayEcosystems = allEcosystems
                .filter {
                    let type = true
                    let chain = chain == nil || $0["chains"].arrayValue.map({$0.stringValue}).contains(chain?.apiName)
                    let pinned = pinned ? favoriteModel.isFavorite(id: $0["id"].intValue) : true
                    let search = searchBar.text!.isEmpty || $0["name"].stringValue.range(of: searchBar.text ?? "", options: .caseInsensitive, range: nil, locale: nil) != nil
                    return type && chain && pinned && search
            }

        } else {
            displayEcosystems = allEcosystems.filter {
                let type = $0["type"].stringValue == type
                let chain = chain == nil || $0["chains"].arrayValue.map({$0.stringValue}).contains(chain?.apiName)
                let pinned = pinned ? favoriteModel.isFavorite(id: $0["id"].intValue) : true
                let search = searchBar.text!.isEmpty || $0["name"].stringValue.range(of: searchBar.text ?? "", options: .caseInsensitive, range: nil, locale: nil) != nil
                return type && chain && pinned && search
            }
        }
        
        collectionView.reloadData()
    }
}

extension DappListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        updateCollectionView(selectedType, pinnedFilterButton.isSelected, selectedNetwork)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension DappListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return displayEcosystems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AllDappListCell", for: indexPath) as! AllDappListCell
        let isPinned = favoriteModel.isFavorite(id: displayEcosystems[indexPath.item]["id"].intValue)
        cell.favoriteDelegate = self
        cell.onBindEcosystem(displayEcosystems[indexPath.item], isPinned)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let columns: CGFloat = 2
        let collectionViewWidth = collectionView.bounds.width - 16
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let spaceBetweenCells = flowLayout.minimumInteritemSpacing * (columns - 1)
        let adjustedWidth = collectionViewWidth - spaceBetweenCells
        let width: CGFloat = adjustedWidth / columns
        let height: CGFloat = width * 1.26
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let ecosystem = displayEcosystems[indexPath.item]
        
        if BaseData.instance.getDappDetailActiveStatus(ecosystem["id"].intValue) {
            let dappDetailSheet = DappDetailSheet(ecosystem: ecosystem,
                                                  favoriteModel: favoriteModel,
                                                  dappDetailVCState: dappDetailVCStateModel)
            let hostingController = UIHostingController(rootView: dappDetailSheet)
            present(hostingController, animated: true)
            
        } else {
            let dappDetail = DappDetailVC(nibName: "DappDetailVC", bundle: nil)
            dappDetail.dappType = .INTERNAL_URL
            dappDetail.dappUrl = URL(string: ecosystem["link"].stringValue)
            dappDetail.targetChain = selectedNetwork
            dappDetail.modalPresentationStyle = .fullScreen
            self.present(dappDetail, animated: true)
        }
        
    }
}

extension DappListViewController: BaseSheetDelegate {
    func onSelectedSheet(_ sheetType: SheetType?, _ result: Dictionary<String, Any>) {
        if sheetType == .SelectDappSort {
            if let index = result["index"] as? Int {
                UserDefaults.standard.set(index, forKey: KEY_DAPP_SORT_OPTION)
                
                switch DappSortType(rawValue: index) ?? .alphabet {
                case .alphabet :
                    allEcosystems.sort {
                        $0["name"].stringValue < $1["name"].stringValue
                    }
                case .networks:
                    allEcosystems.sort {
                        $0["chains"].arrayValue.count > $1["chains"].arrayValue.count
                    }
                }
                
            }
            
        } else if sheetType == .SelectDappNetwork {
            if let chain = result["chain"] as? BaseChain? {
                setNetworkUI(chain)
                selectedNetwork = chain
            } else {
                setNetworkUI()
                selectedNetwork = nil
            }
        }
        
        updateCollectionView(selectedType, pinnedFilterButton.isSelected, selectedNetwork)
    }
    
    
}


//MARK: Cell <-> CollectionView favorite data binding
extension DappListViewController: FavoriteDelegate {
    func setFavoriteData(_ id: Int?, _ isPinned: Bool) {
        if let id {
            if isPinned {
                favoriteModel.favorites.append(id)
            } else {
                if let index = self.favoriteModel.favorites.firstIndex(of: id) {
                    self.favoriteModel.favorites.remove(at: index)
                }
            }
        }
    }
}

//MARK: UIKit <-> SwiftUI favorite data binding
class DappFavoriteModel: ObservableObject {
    @Published var favorites: [Int] = [] {
        didSet {
            saveFavorites()
        }
    }

    init() {
        loadFavorites()
    }

    func isFavorite(id: Int) -> Bool {
        favorites.contains(id)
    }
    
    func toggle(id: Int) {
        if let index = favorites.firstIndex(of: id) {
            favorites.remove(at: index)
        } else {
            favorites.append(id)
        }
    }
    
    private func saveFavorites() {
        UserDefaults.standard.set(favorites, forKey: KEY_DAPP_FAVORITES)
    }
    
    private func loadFavorites() {
        if let savedFavorites = UserDefaults.standard.array(forKey: KEY_DAPP_FAVORITES) as? [Int] {
            favorites = savedFavorites
        }
    }

}

//MARK: DappDetailVC present tigger
class DappDetailVCState: ObservableObject {
    @Published var shouldPresentVC: Bool = false
    @Published var link: String = ""
}


enum DappSortType: Int {
    case alphabet
    case networks
}

struct DappNetwork {
    let chain: BaseChain?
    let dappCount: Int
}
