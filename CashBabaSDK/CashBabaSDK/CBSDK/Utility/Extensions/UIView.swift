//
//  UIView.swift
//  ssl_commerz_revamp
//
//  Created by Mausum Nandy on 5/19/21.
//

import Foundation
import UIKit

public enum SSLBorderSide {
    case pointTop, pointBottom, pointLeft, pointRight
}

extension UIView{
    func addAnchorToSuperview(leading:CGFloat? = nil, trailing:CGFloat? = nil , top:CGFloat? = nil, bottom:CGFloat? = nil, heightMultiplier:CGFloat? = nil,widthMutiplier:CGFloat? = nil,centeredVertically : CGFloat? = nil, centeredHorizontally: CGFloat? = nil,heightWidthRatio:CGFloat? = nil )  {
        if  let superView = self.superview{
            self.translatesAutoresizingMaskIntoConstraints = false
            if let leading = leading {
                self.leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: leading).isActive = true
            }
            if let trailing = trailing {
                self.trailingAnchor.constraint(equalTo: superView.trailingAnchor, constant: trailing).isActive = true
            }
            if let top = top{
                self.topAnchor.constraint(equalTo: superView.topAnchor, constant: top).isActive = true
            }
            if let bottom = bottom{
                self.bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: bottom).isActive = true
            }
            if let heightMultiplier = heightMultiplier{
                self.heightAnchor.constraint(equalTo: superView.heightAnchor, multiplier: heightMultiplier).isActive = true
                if let heightWidthRatio = heightWidthRatio {
                    self.widthAnchor.constraint(equalTo: self.heightAnchor, multiplier: heightWidthRatio).isActive = true
                }
            }
            if let widthMutiplier = widthMutiplier{
                self.widthAnchor.constraint(equalTo: superView.widthAnchor, multiplier: widthMutiplier).isActive = true
                if let heightWidthRatio = heightWidthRatio {
                    self.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: heightWidthRatio).isActive = true
                }
            }
            if let centeredVertically = centeredVertically{
                self.centerYAnchor.constraint(equalTo: superView.centerYAnchor, constant:centeredVertically ).isActive = true
            }
            if let centeredHorizontally = centeredHorizontally{
                self.centerXAnchor.constraint(equalTo: superView.centerXAnchor, constant:centeredHorizontally ).isActive = true
            }
           
        }
       
    }
    @discardableResult
    func addBorders(edges: UIRectEdge,
                    color: UIColor,
                    inset: CGFloat = 0.0,
                    thickness: CGFloat = 1.0) -> [UIView] {

        var borders = [UIView]()

        @discardableResult
        func addBorder(formats: String...) -> UIView {
            let border = UIView(frame: .zero)
            border.backgroundColor = color
            border.translatesAutoresizingMaskIntoConstraints = false
            addSubview(border)
            addConstraints(formats.flatMap {
                NSLayoutConstraint.constraints(withVisualFormat: $0,
                                               options: [],
                                               metrics: ["inset": inset, "thickness": thickness],
                                               views: ["border": border]) })
            borders.append(border)
            return border
        }


        if edges.contains(.top) || edges.contains(.all) {
            addBorder(formats: "V:|-0-[border(==thickness)]", "H:|-inset-[border]-inset-|")
        }

        if edges.contains(.bottom) || edges.contains(.all) {
            addBorder(formats: "V:[border(==thickness)]-0-|", "H:|-inset-[border]-inset-|")
        }

        if edges.contains(.left) || edges.contains(.all) {
            addBorder(formats: "V:|-inset-[border]-inset-|", "H:|-0-[border(==thickness)]")
        }

        if edges.contains(.right) || edges.contains(.all) {
            addBorder(formats: "V:|-inset-[border]-inset-|", "H:[border(==thickness)]-0-|")
        }

        return borders
    }
    
    func addShadow(location: VerticalLocation, color: UIColor = .black, opacity: Float = 0.5, radius: CGFloat = 5.0) {
        switch location {
        case .bottom:
            addShadow(offset: CGSize(width: 0, height: 5), color: color, opacity: opacity, radius: radius)
        case .top:
            addShadow(offset: CGSize(width: 0, height: -1), color: color, opacity: opacity, radius: radius)
        }
    }
    
    func addShadow(offset: CGSize, color: UIColor = .clear, opacity: Float = 0.5, radius: CGFloat = 5.0) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = offset
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = radius
    }
    
    public func sslAddBorder(side: SSLBorderSide, color: UIColor, width: CGFloat, leftPadding:CGFloat = 0, cornerRadious:CGFloat = 0 ) -> UIView {
        let border = UIView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.backgroundColor = color
        if cornerRadious > 0{
            border.layer.cornerRadius = cornerRadious
        }
        self.addSubview(border)
        
        let topConstraint = border.topAnchor.constraint(equalTo: topAnchor)
        let rightConstraint = border.trailingAnchor.constraint(equalTo: trailingAnchor)
        let bottomConstraint = border.bottomAnchor.constraint(equalTo: bottomAnchor)
        let leftConstraint = border.leadingAnchor.constraint(equalTo: leadingAnchor,constant: leftPadding)
        let heightConstraint = border.heightAnchor.constraint(equalToConstant: width)
        let widthConstraint = border.widthAnchor.constraint(equalToConstant: width)
        
        
        switch side {
        case .pointTop:
            NSLayoutConstraint.activate([leftConstraint, topConstraint, rightConstraint, heightConstraint])
        case .pointRight:
            NSLayoutConstraint.activate([topConstraint, rightConstraint, bottomConstraint, widthConstraint])
        case .pointBottom:
            NSLayoutConstraint.activate([rightConstraint, bottomConstraint, leftConstraint, heightConstraint])
        case .pointLeft:
            NSLayoutConstraint.activate([bottomConstraint, leftConstraint, topConstraint, widthConstraint])
        }
        return border
    }
    
}
enum VerticalLocation: String {
    case bottom
    case top
}

extension UIImageView{
    func downloadImage(from url: URL,complition: @escaping (_ image: UIImage?)->Void) {
       
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else {
                complition(nil)
                return
                
            }
           
           
            // always update the UI from the main thread
            DispatchQueue.main.async() { [weak self] in
                self?.image = UIImage(data: data)
                complition(UIImage(data:data))
            }
        }
    }
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        DispatchQueue.global(qos: .background).async {
            URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
        }
       
    }
}
extension UIImage {
    var noir: UIImage? {
        let context = CIContext(options: nil)
        guard let currentFilter = CIFilter(name: "CIPhotoEffectNoir") else { return nil }
        currentFilter.setValue(CIImage(image: self), forKey: kCIInputImageKey)
        if let output = currentFilter.outputImage,
            let cgImage = context.createCGImage(output, from: output.extent) {
            return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
        }
        
        return nil
    }
}

extension CGFloat{
    var x:CGFloat {
        return self*(UIScreen.main.bounds.width/375)
    }
    var y : CGFloat {
        return self*(UIScreen.main.bounds.height/812)
    }
    //Base Design for Iphone 8 Plus
    static let factX = UIScreen.main.bounds.size.width/375
    static let factY = UIScreen.main.bounds.size.height/736
    static func calculatedHeight(_ height:CGFloat)->CGFloat{
        return height * factY
    }
    static func calculatedWidth(_ width:CGFloat)->CGFloat{
        return width * factX
    }
}

extension CALayer {

  func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {

    let border = CALayer()

    switch edge {
    case UIRectEdge.top:
        border.frame = CGRect(x: 0, y: 0, width: frame.width, height: thickness)

    case UIRectEdge.bottom:
        border.frame = CGRect(x:0, y: frame.height - thickness, width: frame.width, height:thickness)

    case UIRectEdge.left:
        border.frame = CGRect(x:0, y:0, width: thickness, height: frame.height)

    case UIRectEdge.right:
        border.frame = CGRect(x: frame.width - thickness, y: 0, width: thickness, height: frame.height)

    default: do {}
    }

    border.backgroundColor = color.cgColor

    addSublayer(border)
 }
}
