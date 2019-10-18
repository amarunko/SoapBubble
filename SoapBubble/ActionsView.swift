//
//  ActionsView.swift
//  EditTableViewCell
//
//  Created by ancheng on 2018/5/18.
//  Copyright © 2018年 ancheng. All rights reserved.
//

import UIKit

protocol ActionsViewDelegate: AnyObject {
    func hideSwipeView()
}

class ActionsView: UIView {

    private var actionViews: [ActionView] = []

    var preferredWidth: CGFloat = 0
    var isConfirming = false
    weak var delegate: ActionsViewDelegate?

    var leftMoveWhenConfirm: (() -> Void)?

    private let actions: [SwipedAction]

    init(actions: [SwipedAction]) {
        self.actions = actions
        super.init(frame: .zero)

        clipsToBounds = true

        for action in actions {
            let actionView = ActionView(action: action)

            actionView.beConfirm = { [weak self] in
                self?.isConfirming = true
            }

            actionView.confirmAnimationCompleted = { [weak self] in
                self?.actionViews.filter({ !$0.isConfirming }).forEach({ $0.isHidden = true })
            }
            addSubview(actionView)

            actionViews.append(actionView)
            actionView.toX = preferredWidth
            preferredWidth += actionView.widthConst
        }
    }

    func setProgress(_ progress: CGFloat) {
        for actionView in actionViews {
            actionView.frame.origin.x = actionView.toX * progress
            actionView.frame.size = bounds.size
            actionView.leftMoveWhenConfirm = leftMoveWhenConfirm
        }
    }

    func setEnabled() {
        actions.forEach({ $0.isEnabled = true })
    }

    func hide() {
        delegate?.hideSwipeView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ActionView: UIView {

    var margin: CGFloat = 10

    var beConfirm: (() -> Void)?
    var leftMoveWhenConfirm: (() -> Void)?
    var confirmAnimationCompleted: (() -> Void)?

    var widthConst: CGFloat {
        return action.preferredWidth ?? (action.title.getWidth(withFont: action.titleFont) + 2 * margin)
    }

    var toX: CGFloat = 0

    private var titleLabel = UILabel()
    private var imageView = UIImageView()
    private let action: SwipedAction
    private var widthConstraint: NSLayoutConstraint?
    private var leadingConstraint: NSLayoutConstraint?

    private(set) var isConfirming = false

    init(action: SwipedAction) {
        self.action = action
        super.init(frame: CGRect.zero)

        margin = action.horizontalMargin
        backgroundColor = action.backgroundColor

        if let image = action.image {
            imageView.image = image
            imageView.contentMode = .center

            addSubview(imageView)
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            leadingConstraint = imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: margin)
            leadingConstraint?.isActive = true
            widthConstraint = imageView.widthAnchor.constraint(equalToConstant: widthConst - 2 * margin)
            widthConstraint?.isActive = true
            imageView.translatesAutoresizingMaskIntoConstraints = false
        } else {
            titleLabel.textColor = action.titleColor
            titleLabel.textAlignment = .center
            titleLabel.text = action.title
            titleLabel.numberOfLines = 0
            titleLabel.font = action.titleFont

            addSubview(titleLabel)

            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            leadingConstraint = titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: margin)
            leadingConstraint?.isActive = true
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            widthConstraint = titleLabel.widthAnchor.constraint(equalToConstant: widthConst - 2 * margin)
            widthConstraint?.isActive = true

            titleLabel.isUserInteractionEnabled = false
        }

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
        isUserInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func didTap() {

        if !action.isEnabled { return }

        if case .custom(let title) = action.needConfirm, !isConfirming {

            isConfirming = true
            beConfirm?()
            titleLabel.text = title
            superview?.bringSubviewToFront(self)

            UIView.animate(withDuration: 0.15, delay: 0, options: [.allowUserInteraction], animations: {
                [weak self] in
                guard let self = self else {
                    return
                }
                self.frame.origin.x = 0
                self.widthConstraint?.constant = title.getWidth(withFont: self.action.titleFont)
                if let superView = self.superview as? ActionsView {
                    let deleteWidth = title.getWidth(withFont: self.action.titleFont) + 2 * self.margin
                    if superView.preferredWidth < deleteWidth {
                        superView.preferredWidth = deleteWidth
                        self.leftMoveWhenConfirm?()
                    } else {
                        self.leadingConstraint?.constant = (superView.preferredWidth - title.getWidth(withFont: self.action.titleFont)) / 2
                    }
                }
                self.layoutIfNeeded()
                }, completion: { [weak self] (_) in
                    self?.confirmAnimationCompleted?()
            })
        } else {
            action.handler?(action)

            if let superView = self.superview as? ActionsView, action.hideOnTap {
                superView.hide()
            }
        }
    }

}
