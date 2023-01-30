//
//  ViewModel.swift
//  Images
//
//  Created by Hidayat Abisena on 27.01.2023.
//

import UIKit

extension HomeViewController {

	class ViewModel {
		private var results: [Release] = []
		
		var coverSize: CGSize = CGSize(width: 100, height: 100)
		
		var onResultsReceived: (() -> Void)?
		
		var onError: ((String) -> Void)?
		
		// MARK: Actions
		
		func fetchResults(withQuery query: String) {
			APIServices.Client.shared.get(.search(query: query)) { (result: Result<APIServices.Types.Response.ArtistSearch, APIServices.Types.Error>) in
				DispatchQueue.main.async {
					switch result {
					case .success(let success):
						self.parseResults(success)
					case .failure(let failure):
						self.onError?(failure.localizedDescription)
					}
				}
				
			}
		}
		
		func handleReleaseSelection(at indexPath: IndexPath) {
			guard indexPath.row >= 0 && indexPath.row < results.count else {
				return
			}
			
			let release = results[indexPath.row]
			APIServices.Client.shared.get(.lookup(id: release.artistId)) { (result: Result<APIServices.Types.Response.ArtistLookup, APIServices.Types.Error>) in
				DispatchQueue.main.async {
					switch result {
					case .success(let success):
						print("The artist details came in: \(success)")
					case .failure(let failure):
						print("Error while getting artist info: \(failure.localizedDescription)")
					}
				}
			}
		}
		
		// MARK: - Private
		
		private func parseResults(_ results: APIServices.Types.Response.ArtistSearch) {
			var localResults = [Release]()
			
			for result in results.results {
				let localResult = Release(id: result.trackId, imageUrl: convertCoverUrl(result.artworkUrl100), title: result.trackName, artistId: result.artistId)
				localResults.append(localResult)
			}
			
			self.results = localResults
			onResultsReceived?()
		}
		
		private func convertCoverUrl(_ from: String) -> URL {
			let coverString = from.replacingOccurrences(of: "100x100", with: "\(Int(coverSize.width))x\(Int(coverSize.height))")
			return URL(string: coverString)!
		}
		
		// MARK: Data source
		
		func coverURL(for indexPath: IndexPath) -> URL? {
			guard indexPath.row >= 0 && indexPath.row < results.count else {
				return nil
			}
			return results[indexPath.row].imageUrl
		}
		
		func numberOfResults() -> Int {
			return results.count
		}
	}

}

extension HomeViewController.ViewModel {
	struct Release {
		var id: Int
		var imageUrl: URL
		var title: String
		var artistId: Int
	}
}
