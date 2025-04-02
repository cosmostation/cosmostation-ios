//
//  DappDetailSheet.swift
//  Cosmostation
//
//  Created by 차소민 on 3/21/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import SwiftUI
import SwiftyJSON

struct DappDetailSheet: View {
    let ecosystem: JSON

    @ObservedObject var favoriteModel: DappFavoriteModel            // favorite binding
    @ObservedObject var dappDetailVCState: DappDetailVCState        // dappDetailVC present trigger
    
    @Environment(\.dismiss) private var dismiss                     // SwiftUI sheet dismiss
    
    @State private var selectedSocialURL: SocialURL?                // social sheet present binding data (Identifiable)
    
    var rows: [GridItem] = Array(repeating: .init(.flexible()), count: 3)   // support network collectionview row
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Text(ecosystem["link"].stringValue)
                    .font(.system6)
                
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    Image(uiImage: UIImage(named: "iconClear")!)
                        .foregroundStyle(Color.base03)
                }
                .frame(width: 24, height: 24)
            } //title (link + closeBtn)
            .padding(.top, 20)
            .padding(.bottom, 10)
            .padding(.horizontal, 8)
            
            DividerView()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading) {
                    HStack {
                        Spacer()
                        AsyncImage(url: URL(string: ecosystem["thumbnail"].stringValue)){ image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Image(uiImage: UIImage(named: "imgDefaultDapp")!)
                                .resizable()
                        }
                        .frame(width: 240, height: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        Spacer()
                    } //thumbnail
                    .padding(.top, 16)
                    .padding(.bottom, 20)
                    HStack {
                        Text(ecosystem["name"].stringValue)
                            .foregroundStyle(Color.white)
                            .font(Font.system6)
                        
                        Text(ecosystem["type"].stringValue)
                            .font(.system14)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .foregroundStyle(Color.white)
                            .background(Color.mintColor)
                            .clipShape(Capsule())
                        
                        Spacer()
                        
                        Button {
                            favoriteModel.toggle(id: ecosystem["id"].intValue)
                            
                        } label: {
                            Image(uiImage: UIImage(named: favoriteModel.isFavorite(id: ecosystem["id"].intValue) ? "iconStarFill" : "iconStar")!)
                                .resizable()
                                .frame(width: 20, height: 20)
                        }
                        .frame(width: 50, height: 20)
                    } //dappName + typeTag + favoriteBtn
                    .padding(.bottom, 6)
                    .padding(.horizontal, 8)

                    Text(ecosystem["description"].stringValue) //dappDescription
                        .foregroundStyle(Color.base03)
                        .font(.system11)
                        .lineSpacing(3)
                        .padding(.bottom, 20)
                        .padding(.horizontal, 8)

                    DividerView()
                        .padding(.bottom, 20)
                    
                    Text("Supported Network")   //Supported Network title
                        .foregroundStyle(Color.white)
                        .font(.system6)
                        .padding(.bottom, 12)
                        .padding(.horizontal, 8)

                    
                    LazyVGrid(columns: rows, alignment: .leading, spacing: 10) {
                        ForEach(
                            ecosystem["chains"].arrayValue.compactMap({ chainJSON in
                                let chainID = chainJSON.stringValue
                                return ALLCHAINS().first(where: { $0.apiName == chainID })
                            }), 
                            id: \.apiName
                        ) { chain in
                            HStack(spacing: 2) {
                                Image(uiImage: UIImage(named: chain.logo1)!)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 16, height: 16)
                                Text(chain.name.uppercased())
                                    .foregroundStyle(Color.base03)
                                    .font(.system15)
                            }
                        }
                    } //chain collectionView (chainLogo + name)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 20)
                    .padding(.horizontal, 8)

                    DividerView()
                        .padding(.bottom, 20)
                    
                    Text("Social Community") //Social title
                        .foregroundStyle(Color.white)
                        .font(.system6)
                        .padding(.bottom, 12)
                        .padding(.horizontal, 8)
                    
                    LazyHStack(spacing: 20) {
                        ForEach(
                            Array(ecosystem["socials"].dictionaryValue).sorted {
                                return $0.key.description < $1.key.description
                            },
                            id: \.key
                        ) { (key, social) in
                            Button {
                                selectedSocialURL = SocialURL(urlString: social.stringValue)
                            } label: {
                                Image(uiImage: UIImage(named: key.description.lowercased()) ?? UIImage(systemName: "circle.fill")!)
                                    .resizable()
                                    .frame(width: 20, height:20)
                            }
                            .foregroundStyle(Color.base04)
                            .sheet(item: $selectedSocialURL) { social in
                                if let url = URL(string: social.urlString) {
                                    SafariView(url: url)
                                } else {
                                    Text("Invalid URL")
                                }
                                
                            }
                        }
                    } //Social StackView (image)
                    .padding(.horizontal, 8)

                }
            } //content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            HStack(spacing: 8) {
                Button("Hide for 7 Days") {
                    BaseData.instance.setDappDetailHideTime(ecosystem["id"].intValue)
                    dismiss()
                    dappDetailVCState.link = ecosystem["link"].stringValue
                    dappDetailVCState.shouldPresentVC = true
                } //Hide 7 Days Btn
                .frame(maxWidth: .infinity, maxHeight: 54)
                .font(.system6)
                .foregroundStyle(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.white, lineWidth: 1)
                )
                
                Button {
                    dismiss()

                    dappDetailVCState.link = ecosystem["link"].stringValue
                    dappDetailVCState.shouldPresentVC = true
                } label: {
                    HStack {
                        Text("Go To Dapp")
                        Image(uiImage: UIImage(named: "iconRedirect")!)
                            .resizable()
                            .frame(width: 16, height: 16)
                    }
                } //Go to Dapp Btn
                .frame(maxWidth: .infinity, maxHeight: 54)
                .font(.system6)
                .foregroundStyle(Color.white)
                .background(Color.mainPurple)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            } //close buttons
            .frame(maxWidth: .infinity, maxHeight: 54)
        } //root
        .padding(.horizontal, 12)
        .background(Color.base09)
    }
}


//MARK: Social safari sheet, Model
import SafariServices

struct SafariView: UIViewControllerRepresentable {

    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.modalPresentationStyle = .popover
        return safariViewController
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) { }
}

struct SocialURL: Identifiable {
    let id = UUID()
    let urlString: String
}


//MARK: Custom Divider
struct DividerView: View {
    var body: some View {
        Rectangle()
            .frame(maxWidth: .infinity, maxHeight: 1)
            .foregroundStyle(Color.base08)
    }
}


//MARK: Color+
extension Color {
    static var mainPurple = Color.init(uiColor: UIColor.colorPrimary)
    static var mintColor = Color.init(hexString: "#09B8C1")
    static var base03 = Color.init(uiColor: UIColor.color03)
    static var base04 = Color.init(uiColor: UIColor.color04)
    static var base08 = Color.init(uiColor: UIColor.color08)
    static var base09 = Color.init(uiColor: UIColor.colorBg)
    
    init(hexString: String) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.currentIndex = "#".endIndex
        }
        var color: UInt64 = 0
        scanner.scanHexInt64(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue)
    }
}

//MARK: Font+
extension Font {
    static var system6 = Font.custom("SpoqaHanSansNeo-Bold", size: 16)
    static var system11 = Font.custom("SpoqaHanSansNeo-Medium", size: 12)
    static var system14 = Font.custom("SpoqaHanSansNeo-Bold", size: 11)
    static var system15 = Font.custom("SpoqaHanSansNeo-Medium", size: 11)
}
