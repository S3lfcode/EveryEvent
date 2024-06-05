//
//  ChatTableViewCell.swift
//  EveryEvent
//
//  Created by S3lfcode on 07.05.2024.
//

import Foundation
import UIKit
import SDWebImage

class ConversationTableViewCell: UITableViewCell {
    static let identifier = "ConversationTableViewCell"

    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 50
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        
        return label
    }()
    
    private lazy var userMessagelabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(userMessagelabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        userImageView.frame = CGRect(x: 10, y: 10, width: 100, height: 100)
        userNameLabel.frame = CGRect(
            x: userImageView.bounds.maxX + 30,
            y: 10,
            width: contentView.bounds.width - 60 - userImageView.bounds.width,
            height: (contentView.bounds.height-20)/2
        )
        userMessagelabel.frame = CGRect(
            x: userImageView.bounds.maxX + 30,
            y: userNameLabel.bounds.maxY + 10,
            width: contentView.bounds.width - 60 - userImageView.bounds.width,
            height: (contentView.bounds.height-20)/2
        )
    }
    
    public func configure(with model: Conversation) {
        self.userMessagelabel.text = model.latestMessage.text
        self.userNameLabel.text = model.name
        
        let path = "images/\(model.otherUserEmail)_profile_picture.png"
        StorageService.shared.downloadURL(for: path) { [weak self] result in
            switch result {
            case .success(let url):
                DispatchQueue.main.async {
                    self?.userImageView.sd_setImage(with: url, completed: nil)
                }
            case .failure(let error):
                print("failed to get image url: \(error)")
            }
        }
    }
}
