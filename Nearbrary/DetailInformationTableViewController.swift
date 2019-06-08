//
//  DetailInformationTableViewController.swift
//  Nearbrary
//
//  Created by Release on 01/06/2019.
//  Copyright © 2019 Jungwon Lee. All rights reserved.
//

import UIKit
import os.log
import SafariServices


class DetailInformationTableViewController: UITableViewController {

    var nowBook:book?=nil
    
    @IBOutlet var booktitle: UILabel!
    @IBOutlet var author: UILabel!
    @IBOutlet var publisher: UILabel!
    @IBOutlet var pubdate: UILabel!
    @IBOutlet var isbnlabel: UILabel!
    @IBOutlet var link: UILabel!
    
    @IBOutlet var bookImageView: UIImageView!
    
    struct AllInfo: Decodable {
        let sogang: [BookInfo]
        let yonsei: [BookInfo]
        let ewha: [BookInfo]
        let hongik: [BookInfo]
    }
    
    struct BookInfo: Decodable {
        let no: String?
        let location: String?
        let callno: String?
        let id: String?
        let status: String?
        let returndate: String?
        
        enum CodingKeys:String,CodingKey{
            case no
            case location
            case callno
            case id
            case status
            case returndate
        }
        
        init(from decoder: Decoder) throws {
            let bookinfo = try decoder.container(keyedBy: CodingKeys.self)
            no = try bookinfo.decode(String.self, forKey: .no) ?? ""
            location = try bookinfo.decode(String.self, forKey: .location) ?? ""
            callno = try bookinfo.decode(String.self, forKey: .callno) ?? ""
            id = try bookinfo.decode(String.self, forKey: .id) ?? ""
            status = try bookinfo.decode(String.self, forKey: .status)
            returndate = try bookinfo.decode(String.self, forKey: .returndate)
        }
    }

    
    var allinfo:AllInfo?
    func requestAWSLambdaAPI(isbn:String,url:URL)->Bool{
        var urlRequest = URLRequest(url:url)
        var flag:Bool = true
        URLSession.shared.dataTask(with: urlRequest) { (data, response, err) in
            guard let data = data else {return}
            
            do {
                let allinfo = try JSONDecoder().decode(AllInfo.self, from: data)
                if allinfo.sogang.count + allinfo.yonsei.count + allinfo.ewha.count + allinfo.hongik.count == 0{
                    NSLog("there's no books in Library with isbn:\(isbn)")
                    flag = false
                }
                else{
                    self.allinfo = allinfo
                    print("in sogang, \(self.allinfo?.sogang) + val num : \(self.allinfo?.sogang.count)\n")
                    print("in yonsei, \(self.allinfo?.yonsei) + val num : \(self.allinfo?.yonsei.count)\n")
                    print("in ewha, \(self.allinfo?.ewha)\n")
                }
            } catch let jsonErr {
                print("Error", jsonErr)
            }
            }.resume()
        return flag
    }
    func getBookInfoFromLibrary(){
        let address_call_lamda = "https://kw7eq88ls8.execute-api.ap-northeast-2.amazonaws.com/Prod/libinfo?isbn="
        
        //let bookinfolist = Array<AllInfo>()
        var flag_bookExist:Int = 0//0:
        let isbns = nowBook?.isbn?.components(separatedBy: " ")
        
        isbns?.forEach{isbn in
            NSLog("isbn Nums from Naver : \(isbn)")
        }
        let urlString = address_call_lamda + (isbns?[0])!
        NSLog("url address to lambda:" + urlString)
        
        guard let url = URL(string:urlString) else {
            NSLog("Request URL to Lambda is not available")
            return
        }
        
        if !requestAWSLambdaAPI(isbn: (isbns?[0])!,url: url){
            flag_bookExist += 1
            let bool = requestAWSLambdaAPI(isbn: (isbns?[1])!, url: url)
            if !bool{
                flag_bookExist += 1
            }
        }
        /*
         이게 http요청 받아와서 codable객체로 받아오는 거보다 먼저 실행된다.
        print("in sogang, \(self.allinfo?.sogang)\n")
        print("in yonsei, \(self.allinfo?.yonsei)\n")
        print("in ewha, \(self.allinfo?.ewha)\n")
        */
        
        
        //store and show bookinfo
        //....
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //NSLog("isbn:\(nowBook?.isbn!)")
        booktitle.text=nowBook?.title
        author.text=nowBook?.author
        publisher.text=nowBook?.publisher
        pubdate.text=nowBook?.pubdate
        let cut_isbn=nowBook?.isbn?.components(separatedBy: " ")
        isbnlabel.text=cut_isbn?[0]
        link.text=nowBook?.link
        bookImageView.image=nowBook?.image
        
        getBookInfoFromLibrary()

     //   
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
