import Foundation
import UIKit
import AsyncDisplayKit
import Display
import SwiftSignalKit
import TelegramPresentationData
import ListSectionHeaderNode
import AppBundle

class ChatListEmptyHeaderItem: ListViewItem {
    let selectable: Bool = false
    
    init() {
    }
    
    func nodeConfiguredForParams(async: @escaping (@escaping () -> Void) -> Void, params: ListViewItemLayoutParams, synchronousLoads: Bool, previousItem: ListViewItem?, nextItem: ListViewItem?, completion: @escaping (ListViewItemNode, @escaping () -> (Signal<Void, NoError>?, (ListViewItemApply) -> Void)) -> Void) {
        async {
            let node = ChatListEmptyHeaderItemNode()
            
            let (nodeLayout, apply) = node.asyncLayout()(self, params, false)
            
            node.insets = nodeLayout.insets
            node.contentSize = nodeLayout.contentSize
            
            Queue.mainQueue().async {
                completion(node, {
                    return (nil, { _ in
                        apply()
                    })
                })
            }
        }
    }
    
    func updateNode(async: @escaping (@escaping () -> Void) -> Void, node: @escaping () -> ListViewItemNode, params: ListViewItemLayoutParams, previousItem: ListViewItem?, nextItem: ListViewItem?, animation: ListViewItemUpdateAnimation, completion: @escaping (ListViewItemNodeLayout, @escaping (ListViewItemApply) -> Void) -> Void) {
        Queue.mainQueue().async {
            assert(node() is ChatListEmptyHeaderItemNode)
            if let nodeValue = node() as? ChatListEmptyHeaderItemNode {
                
                let layout = nodeValue.asyncLayout()
                async {
                    let (nodeLayout, apply) = layout(self, params, nextItem == nil)
                    Queue.mainQueue().async {
                        completion(nodeLayout, { _ in
                            apply()
                        })
                    }
                }
            }
        }
    }
}

class ChatListEmptyHeaderItemNode: ListViewItemNode {
#if DEBUG
    // 提供一个_ASDisplayView的子类即可
    class ChatListEmptyHeaderItemNodeView: ListViewItemNode.ListViewItemNodeView { }
    // 提在ASDisplayNode的子类里重写viewClass方法，返回个_ASDisplayView的子类的类型即可
    override public class func viewClass() -> AnyClass {
        return ChatListEmptyHeaderItemNodeView.self
    }
#endif
    private var item: ChatListEmptyHeaderItem?
    
    required init() {
        super.init(layerBacked: false, dynamicBounce: false)
    }
    
    override func layoutForParams(_ params: ListViewItemLayoutParams, item: ListViewItem, previousItem: ListViewItem?, nextItem: ListViewItem?) {
        let layout = self.asyncLayout()
        let (_, apply) = layout(item as! ChatListEmptyHeaderItem, params, nextItem == nil)
        apply()
    }
    
    func asyncLayout() -> (_ item: ChatListEmptyHeaderItem, _ params: ListViewItemLayoutParams, _ isLast: Bool) -> (ListViewItemNodeLayout, () -> Void) {
        return { item, params, last in
            let layout = ListViewItemNodeLayout(contentSize: CGSize(width: params.width, height: 0.0), insets: UIEdgeInsets())
            
            return (layout, { [weak self] in
                if let strongSelf = self {
                    strongSelf.item = item
                    
                    strongSelf.contentSize = layout.contentSize
                    strongSelf.insets = layout.insets
                }
            })
        }
    }
}
