//
//  QCROperation.swift
//  FRATELLI
//
//  Created by Sakshi on 21/02/25.
//

import Foundation

class QCROperation {
    let webRequest = BaseWebService()
    let endPoint = EndPoints()
    func executeUploadImage(localId: Int, param: [String : Any], outerClosure: @escaping ((String?, [String: Any]?, ResponseStatus) -> ())) {
        webRequest.processRequestUsingPostMethod(url: "\(baseUrl)\(endPoint.QCR_IMAGE_UPLOAD)", parameters: param, showLoader: true, contentType: .json) { error, val, result, statusCode in
            print("Post QCR_IMAGE_UPLOAD Data")
            guard error == nil else {
                outerClosure(error, result as? [String: Any], Utility.getStatus(responseCode: statusCode ?? 0))
                return
            }
            guard let responseData = (result as? [String: Any]) else {
                outerClosure(error, nil, Utility.getStatus(responseCode: statusCode ?? 0))
                return
            }
            outerClosure(nil, responseData, Utility.getStatus(responseCode: statusCode ?? 0))
        }
    }
}
