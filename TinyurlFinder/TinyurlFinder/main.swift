//
//  main.swift
//  TinyurlFinder
//
//  Created by Greyson Wright on 7/20/18.
//  Copyright © 2018 Greyson Wright. All rights reserved.
//

import Foundation

class TinyurlFinder: NSObject, URLSessionDataDelegate {
	private let baseURL = "https://tinyurl.com/"
	private var urlSession: URLSession!
	private var task: URLSessionDataTask?
	
	override init() {
		super.init()
		let sessionConfiguration = URLSessionConfiguration.default
		sessionConfiguration.timeoutIntervalForRequest = 30
		urlSession = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
	}
	
	func findURLs(with urlStorePath: String) {
		let tinyURLs: [String] = getFileContents(at: urlStorePath)
		
		let group = DispatchGroup()
		tinyURLs.forEach { (url: String) in
			let fullURL = baseURL + url
			group.enter()
			self.getRedirectURL(with: fullURL, completion: {
				group.leave()
			})
		}
		group.wait()
	}
	
	private func getFileContents(at path: String) -> [String] {
		guard let fileContents = try? readWholeFile(at: path) else {
			return []
		}
		let contentsArray = fileContents.components(separatedBy: "\n")
		return contentsArray
	}
	
	private func readWholeFile(at path: String) throws -> String {
		let fileContents = try String(contentsOfFile: path, encoding: .ascii)
		return fileContents
	}
	
	private func getRedirectURL(with urlString: String, completion: @escaping () -> Void) {
		let url = URL(string: urlString)
		task = urlSession.dataTask(with: url!) { (data, response, error) in
			completion()
		}
		task?.resume()
	}
	
	//MARK: - Interface
	func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
		task.cancel()
		printCSVRow(for: response, request: request)
	}
	
	private func printCSVRow(for response: HTTPURLResponse, request: URLRequest) {
		let responseURLString = "\(response.url!)"
		let path = responseURLString.split(separator: "/")
		print("\(request.url!)^\(path.last!)")
	}
}

func main() {
	if CommandLine.argc < 2 {
		print("Please supply path to Tinyurl Store.")
		return
	}
	
	let urlStorePath = CommandLine.arguments.last!
	let tinyurlFinder = TinyurlFinder()
	tinyurlFinder.findURLs(with: urlStorePath)
}

main()
