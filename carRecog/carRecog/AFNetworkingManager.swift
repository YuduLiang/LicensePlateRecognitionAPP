import Foundation
import AFNetworking


enum HTTPRequestType : Int{
    case GET = 0
    case POST
}

class NetworkTools: AFHTTPSessionManager {

    static let shareInstance : NetworkTools = {
        let tools = NetworkTools()
        tools.responseSerializer.acceptableContentTypes?.insert("text/html")
        return tools
    }()
    
}

extension NetworkTools {
    func request(methodType : HTTPRequestType, urlString : String, parameters : [String : AnyObject], finished :@escaping (_ result : AnyObject?, _ error : Error?)-> ())  {
       
        let successCallBack = {(task :URLSessionDataTask, result : Any) in
            finished(result as AnyObject?, nil)
        }
       
        let failureCallBack = {(task : URLSessionDataTask?, error :Error) in
            finished(nil, error)
        }
        
        if methodType == .GET {
            
            get(urlString, parameters: parameters, progress: nil, success: successCallBack, failure: failureCallBack)
        }else {
            
            post(urlString, parameters: parameters, progress: nil, success: successCallBack, failure: failureCallBack)
            
        }
    }
}
