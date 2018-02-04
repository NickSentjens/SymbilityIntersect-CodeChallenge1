//
//  ViewController.swift
//  SymbilityCodeChallenge
//
//  Created by Nick Sentjens on 2018-02-02.
//  Copyright © 2018 NickSentjens. All rights reserved.
//

import UIKit

protocol UpdateTableProtocol {
    func updateTableView(updatedCrypto: Cryptrocurrency)
}


class CryptoChartsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UpdateTableProtocol {
    
    @IBOutlet weak var tableView: UITableView!
    
    let firstNetworkCallURL = "https://www.cryptocompare.com/api/data/coinlist/"
    let secondNetworkCallURL = "https://min-api.cryptocompare.com/data/price?fsym=%@&tsyms=CAD"

    var cryptocurriences: [Cryptrocurrency] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let urlString = URL(string: firstNetworkCallURL)
        
        let configuration = URLSessionConfiguration.ephemeral
        let session = URLSession(configuration: configuration, delegate: nil, delegateQueue: OperationQueue.main)
        if let urlString = urlString {
            let task = session.dataTask(with: urlString) { (data, response, error) in
                if error == nil {
                    if let data = data {
                        if let json = try? JSONSerialization.jsonObject(with: data, options: []), let cryptoJson = json as? [String: AnyObject] {
                            if let cryptoData = cryptoJson["Data"] as? [String: AnyObject] {
                                for element in cryptoData {
                                    if let individualCrypto = element.value as? [String: AnyObject] {
                                        if let name = individualCrypto["FullName"] as? String, let symbol = individualCrypto["Symbol"] as? String {
                                            var cyrptocurrency = Cryptrocurrency()
                                            cyrptocurrency.name = name
                                            cyrptocurrency.symbol = symbol
                                            cyrptocurrency.hasBeenSelected = false
                                            self.cryptocurriences.append(cyrptocurrency)
                                        }
                                    }
                                }
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
            
            task.resume()
        }

        tableView.delegate = self
        tableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateTableView(updatedCrypto: Cryptrocurrency) {
        for (index, currency) in cryptocurriences.enumerated() {
            if currency.name == updatedCrypto.name {
                cryptocurriences[index] = updatedCrypto
                break
            }
        }
        
        cryptocurriences = cryptocurriences.sorted { $0.hasBeenSelected && !$1.hasBeenSelected }
        
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if cryptocurriences.count > 0 {
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cryptocurriences.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cryptoCell") as? CryptoChartTableViewCell else {
            return UITableViewCell()
        }
        let cryptocurrency = cryptocurriences[indexPath.row]
        
        if cryptocurrency.hasBeenSelected {
            cell.cryptoStarIcon.setImage(UIImage(named: "goldStar.png"), for: .normal)
        } else {
            cell.cryptoStarIcon.setImage(UIImage(named: "starIcon.png"), for: .normal)
        }
        
        cell.cryptoTitleLabel.text = cryptocurrency.name
        if let price = cryptocurrency.price {
            cell.cryptoPriceLabel.text = String(format: "%f", price)
        } else {
            cell.cryptoPriceLabel.text = "Calculating"
            if let symbol = cryptocurrency.symbol {
                let secondURLCall = String(format: secondNetworkCallURL, symbol)
                let secondURL = URL(string: secondURLCall)
                let configuration = URLSessionConfiguration.ephemeral
                let session = URLSession(configuration: configuration, delegate: nil, delegateQueue: OperationQueue.main)
                
                if let secondURL = secondURL {
                    let task = session.dataTask(with: secondURL, completionHandler: { (data, response, error) in
                        if error == nil {
                            if let data = data, let secondJSON = try? JSONSerialization.jsonObject(with: data, options: []), let priceDictionary = secondJSON as? [String: AnyObject]  {
                                
                                if let cryptoPrice = priceDictionary["CAD"] as? Double, let cell = tableView.cellForRow(at: indexPath) as? CryptoChartTableViewCell {
                                    cell.cryptoPriceLabel.text = String(format: "%f", cryptoPrice)
                                    self.cryptocurriences[indexPath.row].price = cryptoPrice
                                }
                            }
                        } else {
                            if let cell = tableView.cellForRow(at: indexPath) as? CryptoChartTableViewCell {
                                cell.cryptoPriceLabel.text = "Error Calculating"
                            }
                        }
                        
                    })
                    task.resume()
                }
            }
        }
        
        cell.cryptoCurrency = cryptocurrency
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

