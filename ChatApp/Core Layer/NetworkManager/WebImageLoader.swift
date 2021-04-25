//
//  WebImageLoader.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 22.04.2021.
//

import UIKit

protocol ImageLoader {
    func loadPreviewImage(for index: Int) -> UIImage?
    func loadLargeImage(for index: Int) -> UIImage?
    var requestSender: IRequestSender { get }
    var config: RequestConfig<ImageListParser> { get }
    func getImageList()
}

class WebImageLoader: ImageLoader {
    var requestSender: IRequestSender = ImageListRequestSender()
    var config = RequestConfig<ImageListParser>(request: ImageListRequest(), parser: ImageListParser())
    var imageList: ImageList?
    var updateView: (Error?) -> Void
    
    init(updateView: @escaping (Error?) -> Void) {
        self.updateView = updateView
        DispatchQueue.global().async { [weak self] in
            self?.getImageList()
        }
    }
    
    func getImageList() {
        requestSender.send(config: config) { (result) in
            switch result {
            case .success(let imageList):
                self.imageList = imageList
                DispatchQueue.main.async { [weak self] in
                    self?.updateView(nil)
                }
            case .failure(let error):
                DispatchQueue.main.async { [weak self] in
                    self?.updateView(error)
                }
            }
        }
    }
    
    func loadPreviewImage(for index: Int) -> UIImage? {
        guard let urlString = imageList?.hits?[index].previewURL,
              let url = URL(string: urlString),
              let data = try? Data(contentsOf: url)
        else { return nil }
        return UIImage(data: data)
    }
    
    func loadLargeImage(for index: Int) -> UIImage? {
        guard let urlString = imageList?.hits?[index].largeImageURL,
              let url = URL(string: urlString),
              let data = try? Data(contentsOf: url)
        else { return nil }
        return UIImage(data: data)
    }
}
