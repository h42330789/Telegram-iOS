import Foundation
import UIKit
import Display
import AsyncDisplayKit
import Postbox
import AccountContext

public class ListMessageNode: ListViewItemNode {
#if DEBUG
    // 提供一个_ASDisplayView的子类即可
    open class ListMessageNodeView: ListViewItemNode.ListViewItemNodeView { }
    // 提在ASDisplayNode的子类里重写viewClass方法，返回个_ASDisplayView的子类的类型即可
//    override public class func viewClass() -> AnyClass {
//        return ListMessageFileItemNodeView.self
//    }
#endif
    var item: ListMessageItem?
    var interaction: ListMessageItemInteraction?
    
    required init() {
        super.init(layerBacked: false, dynamicBounce: false)
    }
    
    func setupItem(_ item: ListMessageItem) {
        self.item = item
    }
    
    override public func layoutForParams(_ params: ListViewItemLayoutParams, item: ListViewItem, previousItem: ListViewItem?, nextItem: ListViewItem?) {
    }
    
    public func asyncLayout() -> (_ item: ListMessageItem, _ params: ListViewItemLayoutParams, _ mergedTop: Bool, _ mergedBottom: Bool, _ dateAtBottom: Bool) -> (ListViewItemNodeLayout, (ListViewItemUpdateAnimation) -> Void) {
        return { _, params, _, _, _ in
            return (ListViewItemNodeLayout(contentSize: CGSize(width: params.width, height: 1.0), insets: UIEdgeInsets()), { _ in
                
            })
        }
    }
    
    public func transitionNode(id: MessageId, media: Media, adjustRect: Bool) -> (ASDisplayNode, CGRect, () -> (UIView?, UIView?))? {
        return nil
    }
    
    public func updateHiddenMedia() {
    }
    
    public func updateSelectionState(animated: Bool) {
    }
}
