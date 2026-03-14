import Foundation

extension Double {
    var formattedDistance: String {
        let distance = Measurement(value: self, unit: UnitLength.kilometers)
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.numberFormatter.maximumFractionDigits = 1
        return formatter.string(from: distance)
    }
    
    var formattedDistanceMiles: String {
        let distance = Measurement(value: self, unit: UnitLength.kilometers)
        let miles = distance.converted(to: .miles)
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.numberFormatter.maximumFractionDigits = 1
        return formatter.string(from: miles)
    }
    
    var formattedSpeed: String {
        let speed = Measurement(value: self, unit: UnitSpeed.kilometersPerHour)
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.numberFormatter.maximumFractionDigits = 1
        return formatter.string(from: speed)
    }
    
    var formattedCurrency: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: self)) ?? "$0.00"
    }
    
    var formattedPercent: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: self / 100)) ?? "0%"
    }
    
    var formattedDuration: String {
        let hours = Int(self) / 3600
        let minutes = Int(self) % 3600 / 60
        let seconds = Int(self) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var formattedCalories: String {
        String(format: "%.0f kcal", self)
    }
    
    var formattedElevation: String {
        let elevation = Measurement(value: self, unit: UnitLength.meters)
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.numberFormatter.maximumFractionDigits = 0
        return formatter.string(from: elevation)
    }
}
