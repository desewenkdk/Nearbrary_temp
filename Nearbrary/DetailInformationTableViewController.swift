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
    
    // MARK : Decodable Structures to get info from library
    struct AllInfo: Decodable {
        let sogang: [BookInfo]
        let yonsei: [BookInfo]
        let ewha: [BookInfo]
        let hongik: [BookInfo]
        
        enum CodingKeys : String,CodingKey{
            case sogang = "sogang"
            case yonsei = "yonsei"
            case ewha = "ewha"
            case hongik = "hongik"
        }
        init(from decoder: Decoder) throws{
            let bookinfo = try decoder.container(keyedBy: CodingKeys.self)
            sogang = try bookinfo.decode([BookInfo].self, forKey: .sogang)
            yonsei = try bookinfo.decode([BookInfo].self, forKey: .yonsei)
            ewha = try bookinfo.decode([BookInfo].self, forKey: .ewha)
            hongik = try bookinfo.decode([BookInfo].self, forKey: .hongik)
        }
    }
    
    struct BookInfo: Decodable {
        let no: String
        let location: String
        let callno: String
        let id: String
        let status: String
        let returndate: String
        
        enum CodingKeys:String,CodingKey{
            case no = "no"
            case location = "location"
            case callno = "callno"
            case id = "id"
            case status = "status"
            case returndate = "returndate"
        }
        
        //현재 초깃값 세팅이 안된다. codable객체를 중첩해서 사용한 것이 원인인지 뭔지 잘 모르겠다. 덕분에, 리스트가 비어있는 걸 이용한 코드가 동작한다.(allinfo.**.count값을 세서 0인 경우에 동작하는 부분.)
        init(from decoder: Decoder) throws {
            let bookinfo = try decoder.container(keyedBy: CodingKeys.self)
            no = try bookinfo.decodeIfPresent(String.self, forKey: .no) ?? "Not in this library"
            location = (try bookinfo.decodeIfPresent(String.self, forKey: .location)) ?? "NOt in this Library"
            callno = try bookinfo.decodeIfPresent(String.self, forKey: .callno) ?? "NOt in this Library"
            id = try bookinfo.decodeIfPresent(String.self, forKey: .id) ?? "NOt in this Library"
            status = try bookinfo.decodeIfPresent(String.self, forKey: .status) ?? "Not in This Library"
            returndate = try bookinfo.decodeIfPresent(String.self, forKey: .returndate) ?? "NOt in this Library"
        }
        
    }
    //MARK : making foldable Table view
    struct cellData{
        var opened = Bool()
        var title = String()
        var sectionData = [BookInfo]()
        
        init(opened:Bool, title:String, sectionData:[BookInfo]){
            self.opened = opened
            self.title = title
            self.sectionData = sectionData
        }
    }
    var tableViewData = [cellData]()
    var flag:Bool = true
    var allinfo:AllInfo?
 
    func getBookInfoFromLibrary(){
     
        let address_call_lambda = "https://kw7eq88ls8.execute-api.ap-northeast-2.amazonaws.com/Prod/libinfo?isbn="
        //   //let bookinfolist = Array<AllInfo>()
        var flag_bookExist:Int = 0//0:
        
        if self.nowBook!.isbn == nil{
            NSLog("There's no ISBN for this book")
            return;
        }
        
        let isbns = nowBook?.isbn?.components(separatedBy: " ")
        

//        guard let url = URL(string:urlString_10) else {
//            NSLog("Request URL to Lambda is not available")
//            return
//        }
//        DispatchQueue.global().sync{
//            self.requestAWSLambdaAPI(isbns:,url: url)
//            print(self.flag)
//        }
//
        let len10 = String(isbns?[0] ?? "")
        let len13 = String(isbns?[1] ?? "")
       
        NSLog("len10:\(String(describing: isbns?[0])) + || + len13:\(String(describing: isbns?[1]))")
        guard let url_len10 = URL(string: address_call_lambda + len10) else{return}
        guard let url_len13 = URL(string: address_call_lambda + len13)else{return}
        
        //ISBN의 길이가 13인 경우에 책이 더 많이 검색되므로 먼저 검색한다.
        //var urlRequest = URLRequest(url:url_len13)
        
        if len13 != ""{
        URLSession.shared.dataTask(with: url_len13) { (data, response, err) in
            NSLog("len13url : \(url_len13)")
            guard let data = data else {return}
            if data.isEmpty{
                NSLog("There's No data responsed from Libraries ISBN Number:\(len13)")
            }
            else{
                do {
                    
                let allinfo = try JSONDecoder().decode(AllInfo.self, from: data)

                    DispatchQueue.main.async{
                        self.allinfo = allinfo
                        print("in sogang, \(self.allinfo?.sogang) + val num : \(self.allinfo?.sogang.count)\n")
                        print("in yonsei, \(self.allinfo?.yonsei) + val num : \(self.allinfo?.yonsei.count)\n")
                        print("in ewha, \(self.allinfo?.ewha)\n")
                        
                        //sectionData[0]:sogang, [1]:yonsei, [2]:ewha, [3]:hongik
                        if self.allinfo?.sogang.count ?? 0 > 0 {
                            self.allinfo?.sogang.forEach{book_in_sogang in
                                self.tableViewData[0].sectionData.append(book_in_sogang)
                            }
                        }
                        if self.allinfo?.yonsei.count ?? 0 > 0 {
                            self.allinfo?.yonsei.forEach{book_in_yonsei in
                                self.tableViewData[1].sectionData.append(book_in_yonsei)
                            }
                        }
                        if self.allinfo?.ewha.count ?? 0 > 0 {
                            self.allinfo?.ewha.forEach{book_in_ewha in
                                self.tableViewData[2].sectionData.append(book_in_ewha)
                            }
                        }
                        if self.allinfo?.hongik.count ?? 0 > 0 {
                            self.allinfo?.hongik.forEach{book_in_hongik in
                                self.tableViewData[3].sectionData.append(book_in_hongik)
                            }
                        }
                        //데이터를 받아온 다음에 표를 다시 그리자
                        self.tableView.reloadData()
                    }
                    
                } catch let jsonErr {
                    print("Error", jsonErr)
                }
            }
            
            }.resume()
            
        }
        else{
            NSLog("there's no ISBN_len13 of this book.")
        }
        if len10 != ""{
        URLSession.shared.dataTask(with: url_len10) { (data, response, err) in
            NSLog("len10url : \(url_len10)")
            guard let data = data else {return}
            if data.isEmpty{
                NSLog("There's No data responsed from Libraries ISBN Number:\(len10)")
            }
            else{
                do {
                    
                    let allinfo = try JSONDecoder().decode(AllInfo.self, from: data)
                    
                    DispatchQueue.main.async{
                        self.allinfo = allinfo
                        print("in sogang, \(self.allinfo?.sogang) + val num : \(self.allinfo?.sogang.count)\n")
                        print("in yonsei, \(self.allinfo?.yonsei) + val num : \(self.allinfo?.yonsei.count)\n")
                        print("in ewha, \(self.allinfo?.ewha)\n")
                        
                        //sectionData[0]:sogang, [1]:yonsei, [2]:ewha, [3]:hongik
                        if self.allinfo?.sogang.count ?? 0 > 0 {
                            self.allinfo?.sogang.forEach{book_in_sogang in
                                self.tableViewData[0].sectionData.append(book_in_sogang)
                            }
                        }
                        if self.allinfo?.yonsei.count ?? 0 > 0 {
                            self.allinfo?.yonsei.forEach{book_in_yonsei in
                                self.tableViewData[1].sectionData.append(book_in_yonsei)
                            }
                        }
                        if self.allinfo?.ewha.count ?? 0 > 0 {
                            self.allinfo?.ewha.forEach{book_in_ewha in
                                self.tableViewData[2].sectionData.append(book_in_ewha)
                            }
                        }
                        if self.allinfo?.hongik.count ?? 0 > 0 {
                            self.allinfo?.hongik.forEach{book_in_hongik in
                                self.tableViewData[3].sectionData.append(book_in_hongik)
                            }
                        }
                        //데이터를 받아온 다음에 표를 다시 그리자
                        self.tableView.reloadData()
                    }
                    
                } catch let jsonErr {
                    print("Error", jsonErr)
                }
            }
            
            }.resume()
        }
        else{
            NSLog("there's no ISBN_len10 of this book.")
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
        
        
        tableViewData = [cellData(opened: false, title: "Sogang",sectionData:[]),cellData(opened: false, title: "Yonsei", sectionData: []),cellData(opened: false, title: "Ewha", sectionData:[]),cellData(opened: false, title: "Hongik", sectionData: []),
        ]
        getBookInfoFromLibrary()
        
     //   
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.tableViewData.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if tableViewData[section].opened == true{
            return tableViewData[section].sectionData.count + 1 // +1을 해줘야, header빼고 데이터 만큼 만든다.
        } else{
            return 1
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dataIndex = indexPath.row - 1
        if indexPath.row == 0{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell_bookinfo_header") as? DetailInformationInfoHeader
                else{
                    return UITableViewCell()
            }
            cell.cell_header.text = tableViewData[indexPath.section].title
            return cell
//
//            cell.textLabel?.text = tableViewData[indexPath.section].title
//            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell_bookinfo_content") as! DetailInformationInfoContents
            
            let bookinfo : BookInfo = tableViewData[indexPath.section].sectionData[dataIndex]
            
            cell.location.text = bookinfo.location
            cell.callno.text=bookinfo.callno
            cell.status.text=bookinfo.status
            if(bookinfo.status=="대출중")
            {
                cell.status.text = bookinfo.status + bookinfo.returndate
            }
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0{
            if self.tableViewData[indexPath.section].opened == true{
                self.tableViewData[indexPath.section].opened = false
                let sections = IndexSet.init(integer: indexPath.section)
                tableView.reloadSections(sections, with: .automatic)
            }
            else{
                self.tableViewData[indexPath.section].opened = true
                let sections = IndexSet.init(integer: indexPath.section)
                tableView.reloadSections(sections, with: .automatic)
            }
            
        }
    }
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
