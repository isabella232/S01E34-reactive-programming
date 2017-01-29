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

class ViewController: UIViewController {
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceSlider: UISlider!
    @IBOutlet weak var countryPicker: UIPickerView!
    @IBOutlet weak var vatLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var buyButton: UIButton!
    
    let viewModel = CountriesViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        // inputs
        countryPicker.dataSource = self
        countryPicker.delegate = self
        viewModel.price <~ priceSlider.reactive.values
            .map { floor(Double($0)) }

        // outputs
        priceLabel.reactive.text <~ viewModel.priceDescription
        vatLabel.reactive.text <~ viewModel.vatDescription
        totalLabel.reactive.text <~ viewModel.adjustedPriceDescription
    }
}

extension ViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.countries.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return viewModel.countries[row]
    }
}

extension ViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        viewModel.selectedIndex.value = row
    }
}
