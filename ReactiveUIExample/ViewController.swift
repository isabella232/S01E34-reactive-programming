//
//  ViewController.swift
//  ReactiveUIExample
//
//  Created by Florian Kugler on 24-01-2017.
//  Copyright © 2017 objc.io. All rights reserved.
//

import UIKit
import ReactiveCocoa
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

class ViewController: UIViewController {
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceSlider: UISlider!
    @IBOutlet weak var countryPicker: UIPickerView!
    @IBOutlet weak var vatLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var buyButton: UIButton!
    
    let webservice = Webservice()
    let countriesDataSource = CountriesDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        countryPicker.dataSource = countriesDataSource
        countryPicker.delegate = countriesDataSource

        let price = Property(
            initial: 500.0,
            then: priceSlider.reactive.values
                .map { floor(Double($0)) }
        )

        priceLabel.reactive.text <~ price
            .map { "\($0) USD" }

        let loadedVAT = countriesDataSource.selectedIndex
            .skipRepeats()
            .map { [unowned self] index in
                self.countriesDataSource.countries[index].lowercased()
            }
            .flatMap(.latest) { [unowned self] country in
                Property(
                    initial: .loading,
                    then: self.webservice.load(vat(country: country))
                        .map(LoadResult.loaded)
                        .flatMapError { SignalProducer(value: LoadResult.failed($0.error)) }
                )
            }

        vatLabel.reactive.text <~ loadedVAT
            .map { $0.described(by: { "\($0) %" }) }

        totalLabel.reactive.text <~ Property
            .combineLatest(loadedVAT, price)
            .map { vat, price in
                vat.map { price * (1 + $0/100) }
                    .described(by: { "\($0) USD" })
            }
    }
}


