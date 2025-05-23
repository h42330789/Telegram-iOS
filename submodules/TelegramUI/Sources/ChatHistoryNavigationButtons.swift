import Foundation
import Foundation
import UIKit
import Display
import AsyncDisplayKit
import TelegramPresentationData
import WallpaperBackgroundNode

final class ChatHistoryNavigationButtons: ASDisplayNode {
#if DEBUG
    class ChatHistoryNavigationButtonsView: _ASDisplayView {
        
    }
    override public class func viewClass() -> AnyClass {
        return ChatHistoryNavigationButtonsView.self
    }
#endif

    struct ButtonState: Equatable {
        var isEnabled: Bool
        
        init(isEnabled: Bool) {
            self.isEnabled = isEnabled
        }
    }
    
    struct DirectionState: Equatable {
        var up: ButtonState?
        var down: ButtonState?
        
        init(up: ButtonState?, down: ButtonState?) {
            self.up = up
            self.down = down
        }
    }
    
    private var theme: PresentationTheme
    private var dateTimeFormat: PresentationDateTimeFormat
    private let isChatRotated: Bool
    
    let reactionsButton: ChatHistoryNavigationButtonNode
    let mentionsButton: ChatHistoryNavigationButtonNode
    let downButton: ChatHistoryNavigationButtonNode
    let upButton: ChatHistoryNavigationButtonNode
    
    var downPressed: (() -> Void)? {
        didSet {
            self.downButton.tapped = self.downPressed
        }
    }
    
    var upPressed: (() -> Void)? {
        didSet {
            self.upButton.tapped = self.upPressed
        }
    }
    
    var reactionsPressed: (() -> Void)?
    var mentionsPressed: (() -> Void)?
    
    var directionButtonState: DirectionState = DirectionState(up: nil, down: nil) {
        didSet {
            if oldValue != self.directionButtonState {
                let _ = self.updateLayout(transition: .animated(duration: 0.3, curve: .spring))
            }
        }
    }
    
    var unreadCount: Int32 = 0 {
        didSet {
            if self.unreadCount != 0 {
                self.downButton.badge = compactNumericCountString(Int(self.unreadCount), decimalSeparator: self.dateTimeFormat.decimalSeparator)
            } else {
                self.downButton.badge = ""
            }
        }
    }
    
    var mentionCount: Int32 = 0 {
        didSet {
            if self.mentionCount != 0 {
                self.mentionsButton.badge = compactNumericCountString(Int(self.mentionCount), decimalSeparator: self.dateTimeFormat.decimalSeparator)
            } else {
                self.mentionsButton.badge = ""
            }
            
            if (oldValue != 0) != (self.mentionCount != 0) {
                let _ = self.updateLayout(transition: .animated(duration: 0.3, curve: .spring))
            }
        }
    }
    
    var reactionsCount: Int32 = 0 {
        didSet {
            if self.reactionsCount != 0 {
                self.reactionsButton.badge = compactNumericCountString(Int(self.reactionsCount), decimalSeparator: self.dateTimeFormat.decimalSeparator)
            } else {
                self.reactionsButton.badge = ""
            }
            
            if (oldValue != 0) != (self.reactionsCount != 0) {
                let _ = self.updateLayout(transition: .animated(duration: 0.3, curve: .spring))
            }
        }
    }
    
    init(theme: PresentationTheme, dateTimeFormat: PresentationDateTimeFormat, backgroundNode: WallpaperBackgroundNode, isChatRotated: Bool) {
        self.isChatRotated = isChatRotated
        self.theme = theme
        self.dateTimeFormat = dateTimeFormat
        
        self.mentionsButton = ChatHistoryNavigationButtonNode(theme: theme, backgroundNode: backgroundNode, type: .mentions)
        self.mentionsButton.alpha = 0.0
        self.mentionsButton.isHidden = true
        
        self.reactionsButton = ChatHistoryNavigationButtonNode(theme: theme, backgroundNode: backgroundNode, type: .reactions)
        self.reactionsButton.alpha = 0.0
        self.reactionsButton.isHidden = true
        
        self.downButton = ChatHistoryNavigationButtonNode(theme: theme, backgroundNode: backgroundNode, type: isChatRotated ? .down : .up)
        self.downButton.alpha = 0.0
        self.downButton.isHidden = true
        
        self.upButton = ChatHistoryNavigationButtonNode(theme: theme, backgroundNode: backgroundNode, type: isChatRotated ? .up : .down)
        self.upButton.alpha = 0.0
        self.upButton.isHidden = true
        
        super.init()
        
        self.addSubnode(self.reactionsButton)
        self.addSubnode(self.mentionsButton)
        self.addSubnode(self.downButton)
        self.addSubnode(self.upButton)
        
        self.reactionsButton.tapped = { [weak self] in
            self?.reactionsPressed?()
        }
        
        self.mentionsButton.tapped = { [weak self] in
            self?.mentionsPressed?()
        }
        
        self.downButton.isGestureEnabled = false
        self.upButton.isGestureEnabled = false
    }
    
    override func didLoad() {
        super.didLoad()
    }
    
    func update(theme: PresentationTheme, dateTimeFormat: PresentationDateTimeFormat, backgroundNode: WallpaperBackgroundNode) {
        self.theme = theme
        self.dateTimeFormat = dateTimeFormat
        
        self.reactionsButton.updateTheme(theme: theme, backgroundNode: backgroundNode)
        self.mentionsButton.updateTheme(theme: theme, backgroundNode: backgroundNode)
        self.downButton.updateTheme(theme: theme, backgroundNode: backgroundNode)
        self.upButton.updateTheme(theme: theme, backgroundNode: backgroundNode)
    }
    
    private var absoluteRect: (CGRect, CGSize)?
    func update(rect: CGRect, within containerSize: CGSize, transition: ContainedViewLayoutTransition) {
        self.absoluteRect = (rect, containerSize)
        
        var reactionsFrame = self.reactionsButton.frame
        reactionsFrame.origin.x += rect.minX
        reactionsFrame.origin.y += rect.minY
        self.reactionsButton.update(rect: reactionsFrame, within: containerSize, transition: transition)
        
        var mentionsFrame = self.mentionsButton.frame
        mentionsFrame.origin.x += rect.minX
        mentionsFrame.origin.y += rect.minY
        self.mentionsButton.update(rect: mentionsFrame, within: containerSize, transition: transition)
        
        var upFrame = self.upButton.frame
        upFrame.origin.x += rect.minX
        upFrame.origin.y += rect.minY
        self.upButton.update(rect: upFrame, within: containerSize, transition: transition)
        
        var downFrame = self.downButton.frame
        downFrame.origin.x += rect.minX
        downFrame.origin.y += rect.minY
        self.downButton.update(rect: downFrame, within: containerSize, transition: transition)
    }
    
    func updateLayout(transition: ContainedViewLayoutTransition) -> CGSize {
        let buttonSize = CGSize(width: 38.0, height: 38.0)
        let completeSize = CGSize(width: buttonSize.width, height: buttonSize.height * 2.0 + 12.0)
        var upOffset: CGFloat = 0.0
        var mentionsOffset: CGFloat = 0.0
        var reactionsOffset: CGFloat = 0.0
        
        if let down = self.directionButtonState.down {
            self.downButton.imageNode.alpha = down.isEnabled ? 1.0 : 0.5
            self.downButton.buttonNode.isEnabled = down.isEnabled
            
            mentionsOffset += buttonSize.height + 12.0
            upOffset += buttonSize.height + 12.0

            self.downButton.isHidden = false
            transition.updateAlpha(node: self.downButton, alpha: 1.0)
            transition.updateTransformScale(node: self.downButton, scale: 1.0)
        } else {
            transition.updateAlpha(node: self.downButton, alpha: 0.0, completion: { [weak self] completed in
                guard let strongSelf = self, completed else {
                    return
                }
                strongSelf.downButton.isHidden = true
            })
            transition.updateTransformScale(node: self.downButton, scale: 0.2)
        }
        
        if let up = self.directionButtonState.up {
            self.upButton.imageNode.alpha = up.isEnabled ? 1.0 : 0.5
            self.upButton.buttonNode.isEnabled = up.isEnabled
            
            mentionsOffset += buttonSize.height + 12.0

            self.upButton.isHidden = false
            transition.updateAlpha(node: self.upButton, alpha: 1.0)
            transition.updateTransformScale(node: self.upButton, scale: 1.0)
        } else {
            transition.updateAlpha(node: self.upButton, alpha: 0.0, completion: { [weak self] completed in
                guard let strongSelf = self, completed else {
                    return
                }
                strongSelf.upButton.isHidden = true
            })
            transition.updateTransformScale(node: self.upButton, scale: 0.2)
        }
        
        if self.mentionCount != 0 {
            reactionsOffset += buttonSize.height + 12.0
            
            self.mentionsButton.isHidden = false
            transition.updateAlpha(node: self.mentionsButton, alpha: 1.0)
            transition.updateTransformScale(node: self.mentionsButton, scale: 1.0)
        } else {
            transition.updateAlpha(node: self.mentionsButton, alpha: 0.0, completion: { [weak self] completed in
                guard let strongSelf = self, completed else {
                    return
                }
                strongSelf.mentionsButton.isHidden = true
            })
            transition.updateTransformScale(node: self.mentionsButton, scale: 0.2)
        }
        
        if self.reactionsCount != 0 {
            self.reactionsButton.isHidden = false
            transition.updateAlpha(node: self.reactionsButton, alpha: 1.0)
            transition.updateTransformScale(node: self.reactionsButton, scale: 1.0)
        } else {
            transition.updateAlpha(node: self.reactionsButton, alpha: 0.0, completion: { [weak self] completed in
                guard let strongSelf = self, completed else {
                    return
                }
                strongSelf.reactionsButton.isHidden = true
            })
            transition.updateTransformScale(node: self.reactionsButton, scale: 0.2)
        }
        
        if self.isChatRotated {
            transition.updatePosition(node: self.downButton, position: CGRect(origin: CGPoint(x: 0.0, y: completeSize.height - buttonSize.height), size: buttonSize).center)
            transition.updatePosition(node: self.upButton, position: CGRect(origin: CGPoint(x: 0.0, y: completeSize.height - buttonSize.height - upOffset), size: buttonSize).center)
            transition.updatePosition(node: self.mentionsButton, position: CGRect(origin: CGPoint(x: 0.0, y: completeSize.height - buttonSize.height - mentionsOffset), size: buttonSize).center)
            transition.updatePosition(node: self.reactionsButton, position: CGRect(origin: CGPoint(x: 0.0, y: completeSize.height - buttonSize.height - mentionsOffset - reactionsOffset), size: buttonSize).center)
        } else {
            transition.updatePosition(node: self.downButton, position: CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: buttonSize).center)
            transition.updatePosition(node: self.upButton, position: CGRect(origin: CGPoint(x: 0.0, y: upOffset), size: buttonSize).center)
            transition.updatePosition(node: self.mentionsButton, position: CGRect(origin: CGPoint(x: 0.0, y: mentionsOffset), size: buttonSize).center)
            transition.updatePosition(node: self.reactionsButton, position: CGRect(origin: CGPoint(x: 0.0, y: mentionsOffset + reactionsOffset), size: buttonSize).center)
        }
        
        if let (rect, containerSize) = self.absoluteRect {
            self.update(rect: rect, within: containerSize, transition: transition)
        }
        
        return completeSize
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let subnodes = self.subnodes {
            for subnode in subnodes {
                if !subnode.isUserInteractionEnabled {
                    continue
                }
                if let result = subnode.hitTest(point.offsetBy(dx: -subnode.frame.minX, dy: -subnode.frame.minY), with: event) {
                    return result
                }
            }
        }
        return nil
    }

    final class SnapshotState {
        fileprivate let downButtonSnapshotView: UIView?

        fileprivate init(
            downButtonSnapshotView: UIView?
        ) {
            self.downButtonSnapshotView = downButtonSnapshotView
        }
    }

    func prepareSnapshotState() -> SnapshotState {
        var downButtonSnapshotView: UIView?
        if !self.downButton.isHidden {
            downButtonSnapshotView = self.downButton.view.snapshotView(afterScreenUpdates: false)!
        }
        return SnapshotState(
            downButtonSnapshotView: downButtonSnapshotView
        )
    }

    func animateFromSnapshot(_ snapshotState: SnapshotState) {
        if self.downButton.isHidden != (snapshotState.downButtonSnapshotView == nil) {
            if self.downButton.isHidden {
            } else {
                self.downButton.layer.animateAlpha(from: 0.0, to: self.downButton.alpha, duration: 0.3)
                self.downButton.layer.animateScale(from: 0.1, to: 1.0, duration: 0.5, timingFunction: kCAMediaTimingFunctionSpring, removeOnCompletion: true)
            }
        }
    }
}
