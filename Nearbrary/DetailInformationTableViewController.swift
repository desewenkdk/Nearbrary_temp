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
    
    var allinfo:AllInfo?
    func requestAWSLambdaAPI(isbn:String,url:URL)->Bool{
        var urlRequest = URLRequest(url:url)
        var flag:Bool = true
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, err) in
            guard let data = data else {return}
            
            do {
                let allinfo = try JSONDecoder().decode(AllInfo.self, from: data)
                if allinfo.sogang.count + allinfo.yonsei.count + allinfo.ewha.count + allinfo.hongik.count == 0{
                    NSLog("there's no books in Library with isbn:\(isbn)")
                    flag = false
                }
                else{
                    DispatchQueue.main.async{
                        self.allinfo = allinfo
                        print("in sogang, \(self.allinfo?.sogang) + val num : \(self.allinfo?.sogang.count)\n")
                        print("in yonsei, \(self.allinfo?.yonsei) + val num : \(self.allinfo?.yonsei.count)\n")
                        print("in ewha, \(self.allinfo?.ewha)\n")
                        //self.allinfo?.sogang.forEach{books_sogang in
                        self.tableViewData.append(cellData(opened: false,title: "Sogang Univ",sectionData:self.allinfo?.sogang ?? []))
                        self.tableViewData.append(cellData(opened: false,title: "Yonsei Univ",sectionData:self.allinfo?.yonsei ?? []))
                        self.tableViewData.append(cellData(opened: false,title: "Ewha Univ",sectionData:self.allinfo?.ewha ?? []))
                        self.tableViewData.append(cellData(opened: false,title: "Hongik Univ",sectionData:self.allinfo?.hongik ?? []))
                        
                        //데이터를 받아온 다음에 표를 다시 그리자
                        self.tableView.reloadData()
                    }
                    
                }
            } catch let jsonErr {
                print("Error", jsonErr)
            }
        }
        task.resume()
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
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell_bookinfo_header")else{return UITableViewCell()
            }
            cell.textLabel?.text = tableViewData[indexPath.section].title
            return cell
        }
        else{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell_bookinfo_content")else{return UITableViewCell()
            }
            let bookinfo : BookInfo = tableViewData[indexPath.section].sectionData[dataIndex]
            
            cell.textLabel?.text = bookinfo.status + "\\" + bookinfo.location + bookinfo.returndate
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
