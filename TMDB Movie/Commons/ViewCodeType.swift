//
//  ViewCodeType.swift
//  TMDB Movie
//
//  Created by Arthur Ferreira on 30/12/25.
//

import Foundation

protocol ViewCodeType {
    func buildViewHierarchy()
    func setupConstraints()
    func setupAdditionalConfiguration()
    func setupView()
}

extension ViewCodeType {
    func setupView() {
        buildViewHierarchy()
        setupConstraints()
        setupAdditionalConfiguration()
    }
    
    func setupAdditionalConfiguration() {}
}
