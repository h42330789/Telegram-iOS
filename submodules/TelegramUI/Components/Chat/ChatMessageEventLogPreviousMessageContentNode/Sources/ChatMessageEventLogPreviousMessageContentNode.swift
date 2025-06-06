import Foundation
import UIKit
import Postbox
import Display
import AsyncDisplayKit
import SwiftSignalKit
import TelegramCore
import ChatMessageBubbleContentNode
import ChatMessageItemCommon
import ChatMessageAttachedContentNode

public final class ChatMessageEventLogPreviousMessageContentNode: ChatMessageBubbleContentNode {
#if DEBUG
    // 提供一个_ASDisplayView的子类即可
    class ChatMessageEventLogPreviousMessageContentNodeView: ChatMessageBubbleContentNode.ChatMessageBubbleContentNodeView { }
    // 提在ASDisplayNode的子类里重写viewClass方法，返回个_ASDisplayView的子类的类型即可
    override public class func viewClass() -> AnyClass {
        return ChatMessageEventLogPreviousMessageContentNodeView.self
    }
#endif
    private let contentNode: ChatMessageAttachedContentNode
    
    override public var visibility: ListViewItemNodeVisibility {
        didSet {
            self.contentNode.visibility = visibility
        }
    }
    
    required public init() {
        self.contentNode = ChatMessageAttachedContentNode()
        
        super.init()
        
        self.addSubnode(self.contentNode)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func asyncLayoutContent() -> (_ item: ChatMessageBubbleContentItem, _ layoutConstants: ChatMessageItemLayoutConstants, _ preparePosition: ChatMessageBubblePreparePosition, _ messageSelection: Bool?, _ constrainedSize: CGSize, _ avatarInset: CGFloat) -> (ChatMessageBubbleContentProperties, CGSize?, CGFloat, (CGSize, ChatMessageBubbleContentPosition) -> (CGFloat, (CGFloat) -> (CGSize, (ListViewItemUpdateAnimation, Bool, ListViewItemApply?) -> Void))) {
        let contentNodeLayout = self.contentNode.asyncLayout()
        
        return { item, layoutConstants, preparePosition, _, constrainedSize, _ in
            var messageEntities: [MessageTextEntity]?
            
            for attribute in item.message.attributes {
                if let attribute = attribute as? TextEntitiesMessageAttribute {
                    messageEntities = attribute.entities
                    break
                }
            }
            
            let title: String = item.presentationData.strings.Channel_AdminLog_MessagePreviousMessage
            let text: String
            if item.message.text.isEmpty {
                text = item.presentationData.strings.Channel_AdminLog_EmptyMessageText
            } else {
                text = item.message.text
            }
            let mediaAndFlags: ([Media], ChatMessageAttachedContentNodeMediaFlags)? = nil
            
            let (initialWidth, continueLayout) = contentNodeLayout(item.presentationData, item.controllerInteraction.automaticMediaDownloadSettings, item.associatedData, item.attributes, item.context, item.controllerInteraction, item.message, true, .peer(id: item.message.id.peerId), title, nil, nil, text, messageEntities, mediaAndFlags, nil, nil, nil, true, layoutConstants, preparePosition, constrainedSize, item.controllerInteraction.presentationContext.animationCache, item.controllerInteraction.presentationContext.animationRenderer)
            
            let contentProperties = ChatMessageBubbleContentProperties(hidesSimpleAuthorHeader: false, headerSpacing: 8.0, hidesBackground: .never, forceFullCorners: false, forceAlignment: .none)
            
            return (contentProperties, nil, initialWidth, { constrainedSize, position in
                let (refinedWidth, finalizeLayout) = continueLayout(constrainedSize, position)
                
                return (refinedWidth, { boundingWidth in
                    let (size, apply) = finalizeLayout(boundingWidth)
                    
                    return (size, { [weak self] animation, synchronousLoads, applyInfo in
                        if let strongSelf = self {
                            strongSelf.item = item
                            
                            apply(animation, synchronousLoads, applyInfo)
                            
                            strongSelf.contentNode.frame = CGRect(origin: CGPoint(), size: size)
                        }
                    })
                })
            })
        }
    }
    
    override public func animateInsertion(_ currentTimestamp: Double, duration: Double) {
        self.layer.animateAlpha(from: 0.0, to: 1.0, duration: 0.25)
    }
    
    override public func animateAdded(_ currentTimestamp: Double, duration: Double) {
        self.layer.animateAlpha(from: 0.0, to: 1.0, duration: 0.25)
    }
    
    override public func animateRemoved(_ currentTimestamp: Double, duration: Double) {
        self.layer.animateAlpha(from: 1.0, to: 0.0, duration: 0.25, removeOnCompletion: false)
    }
    
    override public func animateInsertionIntoBubble(_ duration: Double) {
        self.layer.animateAlpha(from: 0.0, to: 1.0, duration: 0.25)
    }
    
    override public func tapActionAtPoint(_ point: CGPoint, gesture: TapLongTapOrDoubleTapGesture, isEstimating: Bool) -> ChatMessageBubbleContentTapAction {
        if self.bounds.contains(point) {
            let contentNodeFrame = self.contentNode.frame
            return self.contentNode.tapActionAtPoint(point.offsetBy(dx: -contentNodeFrame.minX, dy: -contentNodeFrame.minY), gesture: gesture, isEstimating: isEstimating)
        }
        return ChatMessageBubbleContentTapAction(content: .none)
    }
    
    override public func updateTouchesAtPoint(_ point: CGPoint?) {
        let contentNodeFrame = self.contentNode.frame
        self.contentNode.updateTouchesAtPoint(point.flatMap { $0.offsetBy(dx: -contentNodeFrame.minX, dy: -contentNodeFrame.minY) })
    }
    
    override public func updateHiddenMedia(_ media: [Media]?) -> Bool {
        return self.contentNode.updateHiddenMedia(media)
    }
    
    override public func transitionNode(messageId: MessageId, media: Media, adjustRect: Bool) -> (ASDisplayNode, CGRect, () -> (UIView?, UIView?))? {
        if self.item?.message.id != messageId {
            return nil
        }
        return self.contentNode.transitionNode(media: media)
    }
}

