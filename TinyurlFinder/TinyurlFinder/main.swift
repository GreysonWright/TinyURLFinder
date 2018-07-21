//
//  main.swift
//  TinyurlFinder
//
//  Created by Greyson Wright on 7/20/18.
//  Copyright © 2018 Greyson Wright. All rights reserved.
//

import Foundation

class Row {
	let fullURL: URL
	let path: String
	private var csvString: String {
		get {
			return "\(fullURL)^\(path)"
		}
	}
	
	init(with fullURL: URL, path: String) {
		self.fullURL = fullURL
		self.path = path
	}
	
	func display() {
		print(csvString)
	}
}

class MainClass {
	let baseURL = "https://tinyurl.com/"
	var urlSession: URLSession
	var task: URLSessionDataTask?
	
	init() {
		let sessionConfiguration = URLSessionConfiguration.default
		sessionConfiguration.timeoutIntervalForRequest = 30
		urlSession = URLSession(configuration: sessionConfiguration)
		var rows: [Row] = [];
		let tinyURLs: [String] = getFileContents(at: "/Users/gwright/Desktop/combos.txt")
		let group = DispatchGroup()
		
		tinyURLs.forEach { (url: String) in
			let fullURL = baseURL + url
			group.enter()
			self.getRedirectURL(with: fullURL, completion: { (response) in
				if let response = response {
					let row = Row(with: response.url!, path: url)
					rows.append(row)
					group.leave()
				}
			})
		}
		
		group.wait()
		
		rows.forEach { (row) in
			row.display()
		}
	}
	
	func getFileContents(at path: String) -> [String] {
		guard let fileContents = try? readWholeFile(at: path) else {
			return []
		}
		let contentsArray = fileContents.components(separatedBy: "|")
		return contentsArray
	}
	
	func readWholeFile(at path: String) throws -> String {
		let fileContents = try String(contentsOfFile: path, encoding: .ascii)
		return fileContents
	}
	
	func getRedirectURL(with urlString: String, completion: @escaping (URLResponse?) -> Void) {
		let url = URL(string: urlString)
		task = urlSession.dataTask(with: url!) { (data, response, error) in
			completion(response)
		}
		task?.resume()
	}
}

let _ = MainClass()

