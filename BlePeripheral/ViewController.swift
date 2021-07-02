//
//  ViewController.swift
//  BlePeripheral
//
//  Created by Brian Lin on 2021/6/28.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBPeripheralManagerDelegate {

    var localPeripheralManager: CBPeripheralManager! = nil
    
    let BLEService = "00001901-0000-1000-8000-00805F9B34FD" // generic service
    let BLEService2 = "00001901-0000-1000-8000-00805F9B34FE" // generic service
    // Characteristics
    let CH_READ  = "2AC6A7BF-2C60-42D0-8013-AECEF2A124C0"
    let CH_WRITE = "9B89E762-226A-4BBB-A381-A4B8CC6E1105"

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        localPeripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        localPeripheralManager.delegate = self
    }

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            self.createServices()
        }
        else {
            print("cannot create services. state = " + getState(peripheral: peripheral))
        }
    }
    
    
    func getState(peripheral: CBPeripheralManager) -> String {
        
        switch peripheral.state {
        case .poweredOn :
            return "poweredON"
        case .poweredOff :
            return "poweredOFF"
        case .resetting:
            return "resetting"
        case .unauthorized:
            return "unauthorized"
        case .unknown:
            return "unknown"
        case .unsupported:
            return "unsupported"
        @unknown default:
            return "unknown"
        }
    }
    
    
    func createServices() {
        print("createServices")

        // service
        let serviceUUID = CBUUID(string: BLEService)
        let service = CBMutableService(type: serviceUUID, primary: true)
        
//         characteristic
        var chs = [CBMutableCharacteristic]()

        // Read characteristic
        print("Charac. read : \n" + CH_READ)
        let characteristic1UUID = CBUUID(string: CH_READ)
        let properties: CBCharacteristicProperties = [.read, .notify ]
        let permissions: CBAttributePermissions = [.readable]
        let ch = CBMutableCharacteristic(type: characteristic1UUID, properties: properties, value: nil, permissions: permissions)
        chs.append(ch)

        // Write characteristic
        print("Charac. write : \n" + CH_WRITE)
        let characteristic2UUID = CBUUID(string: CH_WRITE)
        let properties2: CBCharacteristicProperties = [.write, .notify ]
        let permissions2: CBAttributePermissions = [.writeable]
        let ch2 = CBMutableCharacteristic(type: characteristic2UUID, properties: properties2, value: nil, permissions: permissions2)
        chs.append(ch2)
        
//         Create the service, add the characteristic to it
        service.characteristics = chs
        
//        createdService.append(service)
        localPeripheralManager.add(service)
    }
    
    
    // delegate
    // service + Charactersitic added to peripheral
    //
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?){
        print("peripheralManager didAdd service")
        
        if error != nil {
            print(("Error adding services: \(error!.localizedDescription)"))
        }
        else {
            print("service:\n" + service.uuid.uuidString)

            let peripheralName = "11111111-0000-1000-8000-999999999999"
            // Create an advertisement, using the service UUID
            let advertisement: [String : Any] = [
                CBAdvertisementDataServiceUUIDsKey : [service.uuid],
                CBAdvertisementDataLocalNameKey : peripheralName,
                "test": "123"
            ]
            //28 bytes maxu !!!
            // only 10 bytes for the name
            // https://developer.apple.com/reference/corebluetooth/cbperipheralmanager/1393252-startadvertising
            
            // start the advertisement
            print("Advertisement datas: ")
            print(String(describing: advertisement))
            localPeripheralManager.startAdvertising(advertisement)
            
            print("Starting to advertise.")
        }
    }
    

    
    // Advertising done
    //
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?){
        if error != nil {
            print(("peripheralManagerDidStartAdvertising Error :\n \(error!.localizedDescription)"))
        }
        else {
            print("peripheralManagerDidStartAdvertising OK")
        }
    }
    

    // Central request to be notified to a charac.
    //
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        print("peripheralManager didSubscribeTo characteristic :\n" + characteristic.uuid.uuidString)
        
//        if characteristic.uuid.uuidString == CH_READ {
//            self.notifyCharac = characteristic as? CBMutableCharacteristic
//            self.notifyCentral = central
//
//            // start a timer, which will update the value, every xyz seconds.
//            self.notifyValueTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.notifyValue), userInfo: nil, repeats: true)
//        }

    }
    
    
    
    
    
    func respond(to request: CBATTRequest, withResult result: CBATTError.Code) {
        print("respnse requested")
    }
    
    
    
    
    func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
        print("peripheral name changed")
    }
    
    
    
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        print("peripheral service modified")
    }
    

 
    
    
}

