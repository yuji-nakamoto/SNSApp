//
//  Extension.swift
//  SNSApp
//
//  Created by yuji_nakamoto on 2020/03/12.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import Foundation
import UIKit

func timeAgoSinceDate(_ date:Date, currentDate:Date, numericDates:Bool) -> String {
    let calendar = Calendar.current
    let now = currentDate
    let earliest = (now as NSDate).earlierDate(date)
    let latest = (earliest == now) ? date : now
    let components:DateComponents = (calendar as NSCalendar).components([NSCalendar.Unit.minute , NSCalendar.Unit.hour , NSCalendar.Unit.day , NSCalendar.Unit.weekOfYear , NSCalendar.Unit.month , NSCalendar.Unit.year , NSCalendar.Unit.second], from: earliest, to: latest, options: NSCalendar.Options())
    
    if (components.year! >= 2) {
        return "\(components.year!)年前"
    } else if (components.year! >= 1){
        if (numericDates){ return "1年前"
        } else { return "昨年" }
    } else if (components.month! >= 2) {
        return "\(components.month!)ヶ月前"
    } else if (components.month! >= 1){
        if (numericDates){ return "1ヶ月前"
        } else { return "先月" }
    } else if (components.weekOfYear! >= 2) {
        return "\(components.weekOfYear!)週間前"
    } else if (components.weekOfYear! >= 1){
        if (numericDates){ return "1週間前"
        } else { return "先週" }
    } else if (components.day! >= 2) {
        return "\(components.day!)日前"
    } else if (components.day! >= 1){
        if (numericDates){ return "1日前"
        } else { return "昨日" }
    } else if (components.hour! >= 2) {
        return "\(components.hour!)時間前"
    } else if (components.hour! >= 1){
        if (numericDates){ return "1時間前"
        } else { return "数時間前" }
    } else if (components.minute! >= 2) {
        return "\(components.minute!)分前"
    } else if (components.minute! >= 1){
        if (numericDates){ return "1分前"
        } else { return "数分前" }
    } else if (components.second! >= 3) {
        return "\(components.second!)秒前"
    } else { return "今" }
}

extension Date {
    func toString(dateFormat format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}

extension String {
    func estimateFrameForText_1(_ text: String) -> CGRect {
        let size = CGSize(width: 250, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17)], context: nil)
    }
    func estimateFrameForText_2(_ text: String) -> CGRect {
        let size = CGSize(width: 300, height: 500)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17)], context: nil)
    }
}

extension Int {
    func formatNumber() -> String {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = ","
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self))!
    }
}
