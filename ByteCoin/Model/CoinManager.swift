//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    func didUpdatePrice(price: String, currency: String)
    func didFailWithError(error: Error)
}

struct CoinManager {
    
    var delegate: CoinManagerDelegate?
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = SecretValues.get().apiKey
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    func getCoinPrice(for currency: String){
        // 1. Create a URL
        let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        if let url = URL(string: urlString) {
            // 2. Creat a URLSession
            let session = URLSession(configuration: .default)
            // 3. Give the session a task
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let bitCoinPrice = self.parseJSON(safeData) {
                        let priceString = String(format: "%.2f", bitCoinPrice)
                        self.delegate?.didUpdatePrice(price: priceString, currency: currency)
                    }
                }
                
            }
            // 4. Start the task
            task.resume()
        }
    }
    
    func parseJSON(_ data: Data) -> Double? {
        let decoder = JSONDecoder()
        do {
            let decodeData = try decoder.decode(CoinData.self, from: data)
            let lastPrice = decodeData.rate
            print(lastPrice)
            return lastPrice
            
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}


