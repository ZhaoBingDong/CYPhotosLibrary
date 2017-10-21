//
//  CYPhotosKit.swift
//  CYPhotosKit
//
//  Created by 董招兵 on 2017/8/7.
//  Copyright © 2017年 大兵布莱恩特. All rights reserved.
//

import Foundation
import UIKit

public let CYScreenWidth : CGFloat  = UIScreen.main.bounds.size.width
public let CYScreenHeight : CGFloat = UIScreen.main.bounds.size.height

public func imageNameInBundle(name : String) -> String {
    return "ImageBundle.bundle/\(name)"
}

public func bundleWithClass(cls : AnyClass) -> Bundle {
   return Bundle(for:cls)
}

/**
 *  最大选取照片的数量
 */
public let maxSelectPhotoCount : Int       = 9

public let CYAppKeyWindow : UIWindow?      = UIApplication.shared.keyWindow

public var BaseTintColor : UIColor         = UIColor.CYColor(0.0, green: 187.0, blue: 42.0)

/**
 自定义 LOG
 */
public func NSLog<T>(_ msg: T, fileName: String = #file, methodName: String = #function, lineNumber: Int = #line) {
    #if DEBUG
        print("\n\(methodName) \n \(msg)\n")
    #endif
}

public extension UIColor {

    // 根据 RGB 生成一个颜色,透明度是可以设置 0.0 ~ 1.0
    @discardableResult
    public class func CYColor(_ red : CGFloat ,green : CGFloat , blue : CGFloat,alpha : CGFloat) -> UIColor {
        return UIColor(red:(red/255.0), green: (green/255.0), blue: (blue/255.0), alpha: (alpha))
    }
    // 根据 RGB 生成一个颜色,透明度是1.0
    @discardableResult
    public class func CYColor(_ red : CGFloat ,green : CGFloat , blue : CGFloat) -> UIColor {
        return CYColor(red, green: green, blue: blue, alpha: 1.0)
    }

}


