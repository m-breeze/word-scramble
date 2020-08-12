//
//  ViewController.swift
//  WordScramble
//
//  Created by Marina Khort on 09.08.2020.
//  Copyright © 2020 Marina Khort. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

	var allWords = [String]()
	var usedWords = [String]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
		
		navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))
		
		if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
			if let startWords = try? String(contentsOf: startWordsURL) {
				allWords = startWords.components(separatedBy: "\n")
			}
		}
		
		if allWords.isEmpty {
			allWords = ["silkworm"]
		}
		
		startGame()
	}
	
	func startGame() {
		//sets view controller's title to be a random word in the array
		title = allWords.randomElement()
		usedWords.removeAll(keepingCapacity: true)
		tableView.reloadData()
	}

	@objc func refresh() {
		title = allWords.randomElement()
		
		//or call startGame() but there will be removal of all the saved used words
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return usedWords.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
		cell.textLabel?.text = usedWords[indexPath.row]
		return cell
	}

	@objc func promptForAnswer() {
		let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
		ac.addTextField()
		
		let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac] action in
			guard let answer = ac?.textFields?[0].text else { return }
			self?.submit(answer)
		}
		
		ac.addAction(submitAction)
		present(ac, animated: true)
	}
	
	func isPossible(word: String) -> Bool {
		guard var tempWord = title?.lowercased() else { return false }
		
		for letter in word {
			if let position = tempWord.firstIndex(of: letter) {
				tempWord.remove(at: position)
			} else {
				return false
			}
		}
		return true
	}
	
	func isOriginal(word: String) -> Bool {
		return !usedWords.contains(word)
	}
	
	func isReal(word: String) -> Bool {
		let checker = UITextChecker()
		let range = NSRange(location: 0, length: word.utf16.count)
		let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
		
		if word.utf16.count < 3 {
			return false
		}
		if title == word {
			return false
		}
		
		return misspelledRange.location == NSNotFound
	}
	
	func submit(_ answer: String) {
		let lowerAnswer = answer.lowercased()
		
		guard isPossible(word: lowerAnswer) else {
			guard let title = title?.lowercased() else { return }
			showErrorMessage(title: "Word not possible", message: "You can't spell that word from \(title)")
			return
		}
		
		guard isOriginal(word: lowerAnswer) else {
			showErrorMessage(title: "Word used already", message: "Be more original!")
			return
		}
		
		guard isReal(word: lowerAnswer) else {
			showErrorMessage(title: "Word not recognized", message: "You can't just make them up, you know")
			return
		}
		
		usedWords.insert(answer.lowercased(), at: 0)
		
		let indexPath = IndexPath(row: 0, section: 0)
		tableView.insertRows(at: [indexPath], with: .automatic)
		
		return
	}
		
	func showErrorMessage(title: String, message: String) {
		let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
		ac.addAction(UIAlertAction(title: "OK", style: .default))
		present(ac, animated: true)
	}
}

//if we check by the if else statement
	
//		let errorTitle: String
//		let errorMessage: String

//		if isPossible(word: lowerAnswer) {
//			if isOriginal(word: lowerAnswer) {
//				if isReal(word: lowerAnswer) {
//					usedWords.insert(answer, at: 0)
//
//					let indexPath = IndexPath(row: 0, section: 0)
//					tableView.insertRows(at: [indexPath], with: .automatic)
//
//					return
//				} else {
//					errorTitle = "Word not recognized"
//					errorMessage = "You can't just make them up, you know"
//				}
//			} else {
//				errorTitle = "Word used already"
//				errorMessage = "Be more original!"
//			}
//		} else {
//			guard let title = title?.lowercased() else { return }
//			errorTitle = "Word not possible"
//			errorMessage = "You can't spell that word from \(title)"
//		}
//
//		let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
//		ac.addAction(UIAlertAction(title: "OK", style: .default))
//		present(ac, animated: true)
	

