//
//  API.swift
//  Button Up
//
//  Created by Ricky Buchanan on 13/11/2015.
//  Copyright © 2015 Ricky Buchanan. All rights reserved.
//

import Foundation

class APIClient: NSObject {
    // MARK: Properties
    
    /* Shared session */
    var session: NSURLSession
    var cookies: NSHTTPCookieStorage

    // MARK: Initializers
    
    override init() {
        session = NSURLSession.sharedSession()
        cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage()

        super.init()
    }
    
    func request(parameters: [String:String], completionHandler: (result: AnyObject?, success: Bool, message: String?) -> Void) -> NSURLSessionDataTask {
        //debugPrint("APIClient request: \(parameters)")
        
        /* 2/3. Build the URL and configure the request */
        let url = NSURL(string: BaseURL)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        request.setBodyContent(parameters)

        if let headers = NSHTTPCookie.requestHeaderFieldsWithCookies(cookies.cookiesForURL(url)!) as [String:String]? {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
             print("===== TASK RESPONSE START =====")
             print("Data:")
             print(data)
             print("Response:")
             print(response)
             print("Error:")
             print(error)
            
            if data != nil {
                let strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
                
                 print("StrData:")
                 print(strData)
            }
             print("===== TASK RESPONSE END   =====")

            
            /* GUARD: Was there an error? */
            // TODO should figure out how to retry request if the network connection is lost
            guard (error == nil) else {
                
                // Try figuring out what error it was
                var parsedError = String(error)
                let regExp = try! NSRegularExpression(pattern: "NSLocalizedDescription=(.+)\\}", options: NSRegularExpressionOptions.CaseInsensitive)
                let range = NSMakeRange(0, parsedError.characters.count)
                let match = regExp.firstMatchInString(parsedError, options: NSMatchingOptions(), range: range)
                
                if (match != nil) {
                    let range = match!.rangeAtIndex(1) // First capture group
                    parsedError = (parsedError as NSString).substringWithRange(range)
                }
                print("There was an error with your request: \(parsedError)")
                completionHandler(result: nil, success: false, message: "There was an error with your request: \(parsedError)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                var errorMessage: String?
                if let response = response as? NSHTTPURLResponse {
                    errorMessage = "Your request returned an invalid response! Status code: \(response.statusCode)!"
                } else if let response = response {
                    errorMessage = "Your request returned an invalid response! Response: \(response)!"
                } else {
                    errorMessage = "Your request returned an invalid response!"
                }
                print(errorMessage)
                completionHandler(result: nil, success: false, message: errorMessage)
                return
            }
            
            if let httpResponse = response as? NSHTTPURLResponse, let fields = httpResponse.allHeaderFields as? [String : String] {
                let newCookies = NSHTTPCookie.cookiesWithResponseHeaderFields(fields, forURL: response!.URL!)
                self.cookies.setCookies(newCookies, forURL: response!.URL!, mainDocumentURL: nil)
                for cookie in newCookies {
                    var cookieProperties = [String: AnyObject]()
                    cookieProperties[NSHTTPCookieName] = cookie.name
                    cookieProperties[NSHTTPCookieValue] = cookie.value
                    cookieProperties[NSHTTPCookieDomain] = cookie.domain
                    cookieProperties[NSHTTPCookiePath] = cookie.path
                    cookieProperties[NSHTTPCookieVersion] = NSNumber(integer: cookie.version)
                    cookieProperties[NSHTTPCookieExpires] = NSDate().dateByAddingTimeInterval(31536000)
                    
                    let newCookie = NSHTTPCookie(properties: cookieProperties)
                    self.cookies.setCookie(newCookie!)
                    
                    // print("name: \(cookie.name) value: \(cookie.value)")
                }
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                completionHandler(result: nil, success: false, message: "No data was returned by the request!")
                return
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
//            if let parsedData = self.parseJSON(data) {
//                completionHandler(result: parsedData, success: true, message: nil)
//            } else {
//                debugPrint(NSString(data: data, encoding: NSUTF8StringEncoding))
//                
//                completionHandler(result: nil, success: false, message: "Can't parse JSON.")
//            }
            self.parseJSONWithCompletionHandler(data) { result, success, message in
                completionHandler(result: result, success: success, message: message)
            }
        }
        
        /* 7. Start the request */
        task.resume()
        return task
        
    }
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    func parseJSON(data: NSData) -> AnyObject? {
        
        debugPrint(NSString(data: data, encoding: NSUTF8StringEncoding))

        var parsedResult: NSDictionary
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
            
            guard let status = parsedResult["status"] as! String? else {
                print("Can't parse status: \(parsedResult)")
                return nil
            }
            
            if status != "ok" {
                // TODO check here for logged out errors - message format is "You need to login before calling API function ____" and login then retry
                print("Call failed")
                if let message = parsedResult["message"] as? String {
                    print(message)
                }
                return nil
            }
            
            guard let data = parsedResult["data"] else {
                print("Can't find data in \(parsedResult)")
                return nil
            }
            
            return data
            
        } catch {
            print("Could not parse the data as JSON: '\(data)'")
            return nil
        }
    }
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject?, success: Bool, message: String?) -> Void) -> Void {
        
//        debugPrint(NSString(data: data, encoding: NSUTF8StringEncoding))
        
        var parsedResult: NSDictionary
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
            
            guard let status = parsedResult["status"] as! String? else {
                print("Can't parse status: \(parsedResult)")
                completionHandler(result: nil, success: false, message: "Can't parse status: \(parsedResult)")
                return
            }
            
            if status != "ok" {
                // TODO check here for logged out errors - message format is "You need to login before calling API function ____" and login then retry
                print("Call failed")
                if let message = parsedResult["message"] as? String {
                    print(message)
                    completionHandler(result: nil, success: false, message: message)
                } else {
                    completionHandler(result: nil, success: false, message: "Call failed")
                }
                return
            }
            
            guard let data = parsedResult["data"] else {
                print("Can't find data in \(parsedResult)")
                completionHandler(result: nil, success: false, message: "Can't find data in \(parsedResult)")
                return
            }
            
            completionHandler(result: data, success: true, message: nil)
            return
            
        } catch {
            print("Fetch failed: \((error as NSError).localizedDescription)")
            print("Could not parse the data as JSON: '\(data)'")
            completionHandler(result: nil, success: false, message: "Could not parse the data as JSON: '\(data)'")
            return
        }
    }
    
    func getImageData(artFilename: String?, completionHandler: (imageData: NSData?, success: Bool, message: String?) -> Void) {
        
        /* 1. Set the parameters */
        // There are none...
        
        /* 2/3. Build the URL and configure the request */
        let baseURL = NSURL(string: BaseButtonImageURL)!
        var url: NSURL
        if let artFilename = artFilename {
            url = baseURL.URLByAppendingPathComponent(artFilename)
        } else {
            url = baseURL.URLByAppendingPathComponent(ButtonImageDefault)
        }
        let request = NSURLRequest(URL: url)
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your image request: \(error)")
                completionHandler(imageData: nil, success: false, message: "There was an error with your image request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print("Your image request returned an invalid response! Status code: \(response.statusCode)!")
                    completionHandler(imageData: nil, success: false, message: "Your image request returned an invalid response! Status code: \(response.statusCode)!")
                    return

                } else if let response = response {
                    print("Your image request returned an invalid response! Response: \(response)!")
                    completionHandler(imageData: nil, success: false, message: "Your image request returned an invalid response! Response: \(response)!")
                    return

                } else {
                    print("Your image request returned an invalid response!")
                    completionHandler(imageData: nil, success: false, message: "Your image request returned an invalid response!")
                    return

                }
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the image request!")
                completionHandler(imageData: nil, success: false, message: "No data was returned by the image request!")
                return
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            completionHandler(imageData: data, success: true, message: nil)
            return
        }
        
        /* 7. Start the request */
        task.resume()
    }
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> APIClient {
        
        struct Singleton {
            static var sharedInstance = APIClient()
        }
        
        return Singleton.sharedInstance
    }
}

extension NSMutableURLRequest {
    
    /// Populate the HTTPBody of `application/x-www-form-urlencoded` request
    ///
    /// - parameter parameters:   A dictionary of keys and values to be added to the request
    
    func setBodyContent(parameters: [String : String]) {
        let parameterArray = parameters.map { (key, value) -> String in
            return "\(key)=\(value.stringByAddingPercentEscapesForQueryValue()!)"
        }
        // print("Body content: \(parameterArray.joinWithSeparator("&"))")
        HTTPBody = parameterArray.joinWithSeparator("&").dataUsingEncoding(NSUTF8StringEncoding)
    }
}

extension String {
    
    /// Percent escape value to be added to a URL query value as specified in RFC 3986
    ///
    /// This percent-escapes all characters except the alphanumeric character set and "-", ".", "_", and "~".
    ///
    /// http://www.ietf.org/rfc/rfc3986.txt
    ///
    /// - returns:   Return precent escaped string.
    
    func stringByAddingPercentEscapesForQueryValue() -> String? {
        let characterSet = NSMutableCharacterSet.alphanumericCharacterSet()
        characterSet.addCharactersInString("-._~")
        return stringByAddingPercentEncodingWithAllowedCharacters(characterSet)
    }
}