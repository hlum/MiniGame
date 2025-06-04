//
//  FirestoreManger.swift
//  CoreMotionApp
//
//  Created by Hlwan Aung Phyo on 10/30/24.
//

import Foundation
import Firebase
import FirebaseFirestore


// Define ScoreData struct
struct ScoreData {
    let userName: String
    let score: Int
    let date: Timestamp
    
    init(userName: String, score: Int, date: Timestamp) {
        self.userName = userName
        self.score = score
        self.date = date
    }
    
    init(data: [String: Any]) {
        self.userName = data["userName"] as! String
        self.score = data["score"] as! Int
        self.date = data["date"] as? Timestamp ?? Timestamp(date: Date())
    }
}


final class FirestoreManger {
    static let shared = FirestoreManger()
    
    
    
    func storeScore(scoreData:ScoreData){
        let data:[String:Any] = [
            "userName":scoreData.userName,
            "score":scoreData.score
        ]
        Firestore.firestore().collection("scores").document(scoreData.userName).setData(data) { error in
                if let error = error {
                    print("Error writing data to Firestore: \(error.localizedDescription)")
                } else {
                    print("Data successfully written!")
                }
            }
    }
    
    func getHighestScoreForUSer(userName:String) async->Int{
        let snapshot = try? await Firestore.firestore().collection("scores").document(userName).getDocument()
        if let data = snapshot?.data() {
            return data["score"] as? Int ?? 0
        }
        return 0
    }
    
    func getAllScores() async->[ScoreData]{
        var datas:[ScoreData] = []
        let snapshot = try? await Firestore.firestore().collection("scores").order(by: "score", descending: true).getDocuments()
        let documents = snapshot?.documents
        documents?.forEach({ snapshot in
            let data = snapshot.data()
            let scoreData = ScoreData(data: data)
            datas.append(scoreData)
        })
        return datas
    }
    
    
}
