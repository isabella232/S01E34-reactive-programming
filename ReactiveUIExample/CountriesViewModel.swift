//
//  CountriesDataSource.swift
//  ReactiveUIExample
//
//  Created by Florian Kugler on 24-01-2017.
//  Copyright © 2017 objc.io. All rights reserved.
//

import Foundation
import UIKit
import ReactiveSwift
import Result

extension Webservice {
    func load<A>(_ resource: Resource<A>) -> SignalProducer<A, AnyError> {
        return SignalProducer { observer, _ in
            self.load(resource) { result in
                sleep(1)

                switch result {
                case .error(let error):
                    observer.send(error: AnyError(error))
                case .success(let value):
                    observer.send(value: value)
                    observer.sendCompleted()
                }
            }
        }
    }
}

final class CountriesViewModel {
    let countries = ["Germany", "Netherlands"]
    let webservice = Webservice()

    // inputs
    let price = MutableProperty(500.0)
    let selectedIndex = MutableProperty(0)

    // outputs
    let priceDescription: Property<String>
    let vatDescription: Property<String>
    let adjustedPriceDescription: Property<String>

    init() {
        priceDescription = price.map { "\($0) USD" }

        let loadedVAT = selectedIndex
            .skipRepeats()
            .map { [countries] index in
                countries[index].lowercased()
            }
            .flatMap(.latest) { [webservice] country in
                Property(
                    initial: .loading,
                    then: webservice.load(vat(country: country))
                        .map(LoadResult.loaded)
                        .flatMapError { SignalProducer(value: LoadResult.failed($0.error)) }
                )
            }

        vatDescription = loadedVAT
            .map { $0.described(by: { "\($0) USD" }) }

        adjustedPriceDescription = Property
            .combineLatest(loadedVAT, price)
            .map { vat, price in
                vat.map { price * (1 + $0/100) }
                    .described(by: { "\($0) USD" })
            }
    }
}
