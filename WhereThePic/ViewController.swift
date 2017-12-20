//
//  ViewController.swift
//  WhereThePic
//
//  Created by Roberto Osorio-Goenaga on 12/20/17.
//  Copyright © 2017 Roberto Osorio-Goenaga.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//

import UIKit
import Photos
import MapKit

class ViewController: UIViewController {

    @IBOutlet var imageView: UIImageView?
    @IBOutlet var mapView: MKMapView?
    
    let model = RN1015k500()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PHPhotoLibrary.requestAuthorization { status in
            print("Status is \(status)")
        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func selectImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true, completion: nil)
    }
}

extension ViewController: UIImagePickerControllerDelegate {
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        // use the image
        imageView?.image = chosenImage
        if let buffer = chosenImage.pixelBuffer(width: 224, height: 224) {
            do {
                let dict = try model.prediction(data: buffer)
                let sortedArr =  dict.softmax_output.sorted {
                    $0.value > $1.value
                }
                let coords = sortedArr.first.map { (key, value) in
                    (Double(String(key.split(separator: "\t")[1])) ?? 0.0, Double(String(key.split(separator: "\t")[2])) ?? 0.0)
                } ?? (0.0, 0.0)
                let coordinates = CLLocationCoordinate2DMake(coords.0, coords.1)
                mapView?.centerCoordinate = coordinates
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinates
                annotation.title = "Potential location"
                if let otherAnnotations = mapView?.annotations {
                    mapView?.removeAnnotations(otherAnnotations)
                }
                mapView?.addAnnotation(annotation)
            } catch let e as NSError {
                print("Error \(e)")
            }
        } else {
            print("No buffer.")
        }
        dismiss(animated: true, completion: nil)
    }
    
    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension ViewController: UINavigationControllerDelegate {
    
}
