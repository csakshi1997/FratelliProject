//
//  UploadFileToServer.swift
//  FRATELLI
//
//  Created by Sakshi on 19/06/25.
//

import Foundation
import UIKit

class UploadFileToServer {
    let webRequest = BaseWebService()
    let endPoint = EndPoints()
    
    func uploadFileToServer(
        userId: String,
        fileData: Data,
        fileName: String,
        mimeType: String,
        completion: @escaping (Bool, String?) -> Void
    ) {
        let url = URL(string: "https://location.fieldblaze.com/user/tracking/upload-file")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("xK8pQ3rT9sF2yL5", forHTTPHeaderField: "Auth-Id")

        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        // user_id
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"user_id\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(userId)\r\n".data(using: .utf8)!)

        // file
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append(
            "Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!
        )
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n".data(using: .utf8)!)

        // close boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        let task = URLSession.shared.dataTask(with: request) { data, response, error in

            if let error = error {
                print("❌ Upload error:", error.localizedDescription)
                completion(false, error.localizedDescription)
                return
            }

            guard let data = data,
                  let responseString = String(data: data, encoding: .utf8) else {
                completion(false, "Empty server response")
                return
            }

            print("📦 Raw server response:\n\(responseString)")

            // ⚠️ Backend sends PHP warning before JSON — extract JSON safely
            guard let jsonStartIndex = responseString.firstIndex(of: "{") else {
                print("❌ No JSON found in server response")
                completion(false, "Invalid server response")
                return
            }

            let cleanJSONString = String(responseString[jsonStartIndex...])
            guard let jsonData = cleanJSONString.data(using: .utf8) else {
                completion(false, "Invalid JSON data")
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {

                    let status = json["status"] as? String
                    let url = json["url"] as? String
                    let message = json["message"] as? String

                    if status == "success", let publicUrl = url {
                        print("✅ Upload successful:", publicUrl)
                        completion(true, publicUrl)
                    } else {
                        print("❌ Upload failed:", message ?? "Unknown error")
                        completion(false, message)
                    }
                } else {
                    completion(false, "Invalid JSON structure")
                }
            } catch {
                print("❌ JSON parse error:", error)
                completion(false, "JSON parsing failed")
            }
        }

        task.resume()
    }
}
