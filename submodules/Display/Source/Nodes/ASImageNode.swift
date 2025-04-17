import Foundation
import UIKit
import AsyncDisplayKit

open class ASImageNode: ASDisplayNode {
#if DEBUG
    // 提供一个_ASDisplayView的子类即可
    public class ASImageNodeView: _ASDisplayView { }
    // 提在ASDisplayNode的子类里重写viewClass方法，返回个_ASDisplayView的子类的类型即可
//    override public class func viewClass() -> AnyClass {
//        return ASImageNodeView.self
//    }
#endif
    public var image: UIImage? {
        didSet {
            if self.isNodeLoaded {
                if let image = self.image {
                    let capInsets = image.capInsets
                    if capInsets.left.isZero && capInsets.top.isZero && capInsets.right.isZero && capInsets.bottom.isZero {
                        self.contentsScale = image.scale
                        self.contents = image.cgImage
                    } else {
                        ASDisplayNodeSetResizableContents(self.layer, image)
                    }
                } else {
                    self.contents = nil
                }
                if self.image?.size != oldValue?.size {
                    self.invalidateCalculatedLayout()
                }
            }
        }
    }

    public var displayWithoutProcessing: Bool = true

    override public init() {
        super.init()
    }
    
    override open func didLoad() {
        super.didLoad()
        
        if let image = self.image {
            let capInsets = image.capInsets
            if capInsets.left.isZero && capInsets.top.isZero {
                self.contentsScale = image.scale
                self.contents = image.cgImage
            } else {
                ASDisplayNodeSetResizableContents(self.layer, image)
            }
        }
    }
    
    override public func calculateSizeThatFits(_ contrainedSize: CGSize) -> CGSize {
        return self.image?.size ?? CGSize()
    }
}
