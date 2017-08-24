//
//  CYAuthorizedFailureViewController.swift
//  CYPhotosKit
//
//  Created by 董招兵 on 2017/8/9.
//  Copyright © 2017年 大兵布莱恩特. All rights reserved.
//

import UIKit

public class CYAuthorizedFailureViewController: UIViewController {

    private var lockImageView : UIImageView?
    private var settingBtn : UIButton?
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setup()
    }

    private func setup() {

        navigationItem.leftBarButtonItem     = UIBarButtonItem.init(title: "", style: .done, target: self, action: #selector(back))
        navigationItem.rightBarButtonItem    = UIBarButtonItem.init(title: "取消", style: .done, target: self, action: #selector(cancle))
        title                                = "照片"
        if  let url                          = URL(string : "prefs:root=Privacy&path=PHOTOS") {
            settingBtn?.isHidden             = !UIApplication.shared.canOpenURL(url)
        }
        view.backgroundColor                 = .white

    }

    private func setupUI() {

        lockImageView = UIImageView()
        lockImageView?.image                 = CYResourceAssets.locked
        lockImageView?.frame                 = CGRect(x: CYScreenWidth*0.5-47.5, y: 100.0, width: 95.0, height: 126.0)
        view.addSubview(lockImageView!)

        let label                             = UILabel()
        label.textColor                       = UIColor.CYColor(142, green: 145, blue: 148)
        label.textAlignment                   = .center
        label.numberOfLines                   = 0
//        label.backgroundColor    = .red
        view.addSubview(label)
        let message : String                  = """
                                    在"设置-隐私-照片"中开启后即可查看\n
                                   """
        let content = NSMutableAttributedString(string: "此应用没有权限访问你的照片或视频\n", attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15.0)])
        let content2 = NSAttributedString(string: message, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 13.0)])
        content.append(content2)
        label.attributedText         = content
        label.frame                  = CGRect(x: 0.0, y: (lockImageView?.frame.maxY)! + 20.0, width: CYScreenWidth, height: 50.0)

        settingBtn                   = UIButton(type: .custom)
        settingBtn?.setTitle("前往设置", for: .normal)
        settingBtn?.setTitleColor(BaseTintColor, for: .normal)
        settingBtn?.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
        settingBtn?.addTarget(self, action: #selector(settingButtonClick(_:)), for: .touchUpInside)
        settingBtn?.frame            = CGRect(x: CYAppKeyWindow!.frame.midX+5.0, y: label.frame.maxY+5.0, width: 60.0, height: 25.0)
        view.addSubview(settingBtn!)

    }

    @objc private func back() { }
    @objc private func  cancle() {
        NotificationCenter.default.post(name: Notification.Name("photosViewControllDismiss"), object: nil)
    }
    @objc private func settingButtonClick(_ btn : UIButton) {

        if  let url                          = URL(string : "prefs:root=Privacy&path=PHOTOS") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }

    }


}
