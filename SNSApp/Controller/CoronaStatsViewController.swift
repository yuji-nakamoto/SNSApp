//
//  CoronaStatsViewController.swift
//  SNSApp
//
//  Created by yuji_nakamoto on 2020/06/16.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class CoronaStatsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var confCountLbl: UILabel!
    @IBOutlet weak var deathCountLbl: UILabel!
    @IBOutlet weak var recoverCountLbl: UILabel!
    @IBOutlet weak var criticalCountLbl: UILabel!
    @IBOutlet weak var container1: UIView!
    @IBOutlet weak var container2: UIView!
    @IBOutlet weak var container3: UIView!
    @IBOutlet weak var container4: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var countryData: [[String: Any]] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    let headers: HTTPHeaders = [
        "x-rapidapi-host": "covid-19-data.p.rapidapi.com",
        "x-rapidapi-key": "ed5e14c062mshf4d69135b0e0b64p1d0baejsn1cfd8d7d62ea"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        container1.layer.cornerRadius = 10
        container2.layer.cornerRadius = 10
        container3.layer.cornerRadius = 10
        container4.layer.cornerRadius = 10
        navigationItem.title = "新型コロナ感染者の統計"
        getCurrentTotal()
        getAllCountries()
    }
    
    
    func getCurrentTotal() {
        activityIndicator.startAnimating()
        AF.request("https://covid-19-data.p.rapidapi.com/totals?format=json", headers: headers).responseJSON { response in
            
            let result = response.data
            if result != nil {
                let json = JSON(result!)
                print(json)
                
                let confirmed = json[0]["confirmed"].intValue
                let death = json[0]["deaths"].intValue
                let recovered = json[0]["recovered"].intValue
                let critical = json[0]["critical"].intValue
                
                self.confCountLbl.text = confirmed.formatNumber()
                self.deathCountLbl.text = death.formatNumber()
                self.recoverCountLbl.text = recovered.formatNumber()
                self.criticalCountLbl.text = critical.formatNumber()
                
            }
            self.activityIndicator.stopAnimating()
        }
    }
    
    func getAllCountries() {
        AF.request("https://covid-19-data.p.rapidapi.com/country/all?format=json", headers: headers).responseJSON { response in
            
            let result = response.value
            if result != nil {
                let dict = result as! [Dictionary<String, Any>]
                DispatchQueue.main.async {
                    self.countryData = dict
                }
            }
        }
    }
    
    @IBAction func refleshButton(_ sender: Any) {
        getCurrentTotal()
        getAllCountries()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
}

extension CoronaStatsViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countryData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountryCell", for: indexPath as IndexPath)
        let data = self.countryData[indexPath.row]
        
        let country = cell.viewWithTag(1) as! UILabel
        let confirmed = cell.viewWithTag(2) as! UILabel
        let deaths = cell.viewWithTag(3) as! UILabel
        let recovered = cell.viewWithTag(4) as! UILabel
        
        country.text = (data["country"] as! String)
        confirmed.text = (data["confirmed"] as! Int).formatNumber()
        deaths.text = (data["deaths"] as! Int).formatNumber()
        recovered.text = (data["recovered"] as! Int).formatNumber()
        
        return cell
    }
}
