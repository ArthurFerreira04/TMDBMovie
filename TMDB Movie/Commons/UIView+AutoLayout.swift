//
//  UIView+AutoLayout.swift
//  TMDB Movie
//
//  Created by Arthur Ferreira on 30/12/25.
//

import UIKit

extension UIView {
    
    @available(iOS 9, *)
    @discardableResult
    func anchor(
        top: NSLayoutYAxisAnchor? = nil,
        left: NSLayoutXAxisAnchor? = nil,
        bottom: NSLayoutYAxisAnchor? = nil,
        right: NSLayoutXAxisAnchor? = nil,
        centerX: NSLayoutXAxisAnchor? = nil,
        centerY: NSLayoutYAxisAnchor? = nil,
        topConstant: CGFloat = 0,
        leftConstant: CGFloat = 0,
        bottomConstant: CGFloat = 0,
        rightConstant: CGFloat = 0,
        widthConstant: CGFloat = 0,
        heightConstant: CGFloat = 0
    ) -> [NSLayoutConstraint] {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        var anchors = [NSLayoutConstraint]()
        
        if let top = top {
            anchors.append(topAnchor.constraint(equalTo: top, constant: topConstant))
        }
        
        if let left = left {
            anchors.append(leftAnchor.constraint(equalTo: left, constant: leftConstant))
        }
        
        if let bottom = bottom {
            anchors.append(bottomAnchor.constraint(equalTo: bottom, constant: -bottomConstant))
        }
        
        if let right = right {
            anchors.append(rightAnchor.constraint(equalTo: right, constant: -rightConstant))
        }
        
        if let centerX = centerX {
            anchors.append(centerXAnchor.constraint(equalTo: centerX))
        }
        
        if let centerY = centerY {
            anchors.append(centerYAnchor.constraint(equalTo: centerY))
        }
        
        if widthConstant > 0 {
            anchors.append(widthAnchor.constraint(equalToConstant: widthConstant))
        }
        
        if heightConstant > 0 {
            anchors.append(heightAnchor.constraint(equalToConstant: heightConstant))
        }
        
        NSLayoutConstraint.activate(anchors)
        
        return anchors
    }
    
    func anchorTo(superview: UIView) {
        anchor(
            top: superview.topAnchor,
            left: superview.leftAnchor,
            bottom: superview.bottomAnchor,
            right: superview.rightAnchor
        )
    }
    
    @available(iOS 9, *)
    func anchorCenterXToSuperview(constant: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        if let anchor = superview?.centerXAnchor {
            centerXAnchor.constraint(equalTo: anchor, constant: constant).isActive = true
        }
    }
    
    @available(iOS 9, *)
    func anchorCenterYToSuperview(constant: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        if let anchor = superview?.centerYAnchor {
            centerYAnchor.constraint(equalTo: anchor, constant: constant).isActive = true
        }
    }
    
    @available(iOS 9, *)
    func anchorCenterSuperview() {
        anchorCenterXToSuperview()
        anchorCenterYToSuperview()
    }
}

extension UITableView {

    @discardableResult
    func applyTableHeader(_ header: UIView, width: CGFloat) -> CGFloat {
        guard width > 0 else { return 0 }

        header.translatesAutoresizingMaskIntoConstraints = true
        var frame = header.frame
        frame.size.width = width

        let fittingSize = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
        let height = ceil(
            header.systemLayoutSizeFitting(
                fittingSize,
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel
            ).height
        )

        frame.size.height = max(1, height)
        header.frame = frame
        tableHeaderView = header
        tableHeaderView = header
        return frame.size.height
    }
}
