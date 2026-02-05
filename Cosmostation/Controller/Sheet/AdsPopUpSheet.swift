//
//  AdsPopUpSheet.swift
//  Cosmostation
//
//  Created by 권혁준 on 1/21/26.
//  Copyright © 2026 wannabit. All rights reserved.
//

import UIKit

class AdsPopUpSheet: BaseVC {
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var pageContainerView: UIView!
    @IBOutlet weak var indicatorLabel: RoundedPaddingLabel!
    @IBOutlet weak var hideButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    private var pageVC: UIPageViewController!
    private var pages: [SelectAdsInfoCell] = []
    private var currentIndex: Int = 0
    
    var sheetDelegate: BaseSheetDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        popUpView.layer.cornerRadius = 12
        popUpView.layer.borderWidth = 1
        popUpView.layer.borderColor = UIColor.colorBg.cgColor
        popUpView.clipsToBounds = true

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.fontSize12Bold,
            .foregroundColor: UIColor.color01,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
        ]

        let attributedTitle = NSAttributedString(
            string: "Close",
            attributes: attributes
        )
        closeButton.setAttributedTitle(attributedTitle, for: .normal)

        hideButton.configuration?.contentInsets = .zero
        hideButton.configurationUpdateHandler = { button in
            button.configuration?.image =
                button.isSelected
                ? UIImage(named: "iconCheckboxOn")
                : UIImage(named: "iconCheckboxOff")
        }
        
        setupPager()
    }

    @IBAction func onBindHideOption(_ sender: UIButton) {
        sender.isSelected.toggle()
    }

    @IBAction func closePopUpView(_ sender: Any) {
        if hideButton.isSelected {
            let ids = BaseData.instance.adsInfos?.compactMap { $0.id } ?? []
            BaseData.instance.setAdsSet(ids)
        }
        dismiss(animated: true)
    }

    private func setupPager() {
        guard let adsInfos = BaseData.instance.adsInfos, !adsInfos.isEmpty else { return }
        if adsInfos.count == 1 {
            indicatorLabel.isHidden = true
        }

        pageVC = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )
        pageVC.dataSource = self
        pageVC.delegate = self

        pages = adsInfos.map { adsInfo in
            SelectAdsInfoCell(adInfo: adsInfo) { [weak self] onViewAction in
                self?.openWebAndDismiss(adsInfo)
            }
        }

        addChild(pageVC)
        pageContainerView.addSubview(pageVC.view)
        pageVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageVC.view.topAnchor.constraint(equalTo: pageContainerView.topAnchor),
            pageVC.view.leadingAnchor.constraint(equalTo: pageContainerView.leadingAnchor),
            pageVC.view.trailingAnchor.constraint(equalTo: pageContainerView.trailingAnchor),
            pageVC.view.bottomAnchor.constraint(equalTo: pageContainerView.bottomAnchor),
        ])
        pageVC.didMove(toParent: self)

        pageVC.setViewControllers([pages[0]], direction: .forward, animated: false)
        currentIndex = 0
        
        updateIndicator()
    }
    
    private func updateIndicator() {
        guard let adsInfos = BaseData.instance.adsInfos, !adsInfos.isEmpty else { return }
        indicatorLabel.text = "\(currentIndex + 1)/\(adsInfos.count)"
    }
    
    private func openWebAndDismiss(_ info: AdsInfo) {
        guard let urlStr = info.linkUrl?.trimmingCharacters(in: .whitespacesAndNewlines), !urlStr.isEmpty else { return }
        
        if hideButton.isSelected {
            let ids = BaseData.instance.adsInfos?.compactMap { $0.id } ?? []
            BaseData.instance.setAdsSet(ids)
        }

        dismiss(animated: true) { [weak self] in
            self?.sheetDelegate?.onSelectedSheet(.MoveAdsDetail, ["url": urlStr])
        }
    }
}

extension AdsPopUpSheet: UIPageViewControllerDataSource,
    UIPageViewControllerDelegate
{

    func pageViewController(
        _ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? SelectAdsInfoCell, let index = pages.firstIndex(of: vc) else { return nil }
        let prev = index - 1
        return prev >= 0 ? pages[prev] : nil
    }

    func pageViewController(
        _ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? SelectAdsInfoCell, let index = pages.firstIndex(of: vc) else { return nil }
        let next = index + 1
        return next < pages.count ? pages[next] : nil
    }

    func pageViewController(
        _ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed, let current = pageViewController.viewControllers?.first as? SelectAdsInfoCell,
                let index = pages.firstIndex(of: current) else { return }
        currentIndex = index
        updateIndicator()
    }
}
