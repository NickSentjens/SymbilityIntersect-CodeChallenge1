//
//  CryptoChartTableViewCell.swift
//  SymbilityCodeChallenge
//
//  Created by Nick Sentjens on 2018-02-02.
//  Copyright © 2018 NickSentjens. All rights reserved.
//

import UIKit

class CryptoChartTableViewCell: UITableViewCell {
    @IBOutlet weak var cryptoTitleLabel: UILabel!
    @IBOutlet weak var cryptoPriceLabel: UILabel!
    @IBOutlet weak var cryptoStarIcon: UIButton!
    var cryptoCurrency: Cryptrocurrency?
    var delegate: UpdateTableProtocol?
    
    @IBAction func buttonTapped(sender: AnyObject) {
        if cryptoCurrency != nil, delegate != nil {
            if cryptoCurrency!.hasBeenSelected {
                cryptoCurrency!.hasBeenSelected = false
                cryptoStarIcon.setImage(UIImage(named: "starIcon.png"), for: .normal)
                delegate?.updateTableView(updatedCrypto: cryptoCurrency!)
            } else {
                cryptoCurrency!.hasBeenSelected = true
                cryptoStarIcon.setImage(UIImage(named: "goldStar.png"), for: .normal)
                delegate?.updateTableView(updatedCrypto: cryptoCurrency!)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
