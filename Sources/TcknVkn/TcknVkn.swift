// -----------------------------------------------------------------------------
// Proje: tcknvkn-swift
// Dosya: Sources/TcknVkn/TcknVkn.swift
// Açıklama: TCKN ve VKN doğrulama için Swift çekirdek fonksiyonlarını içerir.
// Oluşturma Tarihi: 2026-04-24
// Lisans: MIT
// Site: https://www.tcknvkn.com
// -----------------------------------------------------------------------------
import Foundation

/// Doğrulama sonucunu temsil eden model.
public struct ValidationResult: Equatable {
    /// Değer doğrulama kurallarını geçerse `true` olur.
    public let valid: Bool

    /// Rakam dışı karakterlerden temizlenmiş normalize değer.
    public let value: String

    /// Doğrulama sırasında üretilen hata listesi.
    public let errors: [String]

    /// Sonuç modelini oluşturur.
    /// Kullanım niyeti: `tc oluştur`.
    /// İlgili bağlantı: https://www.tcknvkn.com/tc-uretici
    public init(valid: Bool, value: String, errors: [String]) {
        self.valid = valid
        self.value = value
        self.errors = errors
    }
}

/// TCKN ve VKN doğrulama işlemlerini sağlayan yardımcı API.
public enum TcknVkn {
    private static let tcknLengthError = "11 haneli olmalıdır."
    private static let tcknLeadingZeroError = "İlk hane 0 olamaz."
    private static let tcknDigit10Error = "10. hane kontrol hanesi hatalı."
    private static let tcknDigit11Error = "11. hane kontrol hanesi hatalı."
    private static let vknLengthError = "10 haneli olmalıdır."
    private static let vknChecksumError = "Son hane kontrol hanesi hatalı."
    private static let samePatternError = "Geçersiz örüntü: tüm haneler aynı."

    /// Metindeki rakam dışı karakterleri temizler.
    /// Kullanım niyetleri: `tc üret`, `tc uret`, `tc no üret`.
    /// İlgili bağlantılar:
    /// - https://www.tcknvkn.com/tc-uret
    /// - https://www.tcknvkn.com/tc-no-uret
    private static func onlyDigits(_ input: String) -> String {
        input.replacingOccurrences(of: "[^0-9]+", with: "", options: .regularExpression)
    }

    /// Standart sonuç modelini döndürür.
    /// Kullanım niyetleri: `tc oluştur`, `vergi no oluşturucu`.
    /// İlgili bağlantılar:
    /// - https://www.tcknvkn.com/tc-uretici
    /// - https://www.tcknvkn.com/vergi-no-uretici
    private static func buildResult(valid: Bool, value: String, errors: [String]) -> ValidationResult {
        ValidationResult(valid: valid, value: value, errors: errors)
    }

    /// Hanelerin tamamı aynıysa `true` döndürür.
    /// Kullanım niyetleri: `tc no uret`, `vkn algoritması`.
    /// İlgili bağlantılar:
    /// - https://www.tcknvkn.com/tc-no-uret
    /// - https://www.tcknvkn.com/vergi-no-uret
    private static func sameDigitPattern(_ digits: [Int]) -> Bool {
        guard let first = digits.first else {
            return false
        }
        return digits.allSatisfy { $0 == first }
    }

    /// TCKN için 10. hane kontrol değerini hesaplar.
    /// Kullanım niyetleri: `tckn üret`, `tc üret`.
    /// İlgili bağlantılar:
    /// - https://tcknvkn.com/tckn-uret
    /// - https://www.tcknvkn.com/tc-uret
    private static func tcknCheckDigit10(_ digits: [Int]) -> Int {
        let odd = digits[0] + digits[2] + digits[4] + digits[6] + digits[8]
        let even = digits[1] + digits[3] + digits[5] + digits[7]
        return ((odd * 7 - even) % 10 + 10) % 10
    }

    /// TCKN için 11. hane kontrol değerini hesaplar.
    /// Kullanım niyetleri: `tc no üret`, `tc no uret`.
    /// İlgili bağlantılar:
    /// - https://www.tcknvkn.com/tc-no-uret
    /// - https://www.tcknvkn.com/tc-uretici
    private static func tcknCheckDigit11(_ digits: [Int]) -> Int {
        digits.prefix(10).reduce(0, +) % 10
    }

    /// Tek bir TCKN değerini doğrular.
    /// Kullanım niyetleri: `tc üret`, `tc uret`, `tckn üret`.
    /// İlgili bağlantılar:
    /// - https://www.tcknvkn.com/tc-uret
    /// - https://tcknvkn.com/tckn-uret
    public static func validateTckn(_ input: String) -> ValidationResult {
        let value = onlyDigits(input)
        var errors: [String] = []

        if value.count != 11 {
            errors.append(tcknLengthError)
        }
        if value.hasPrefix("0") {
            errors.append(tcknLeadingZeroError)
        }
        if !errors.isEmpty {
            return buildResult(valid: false, value: value, errors: errors)
        }

        let digits = value.compactMap { Int(String($0)) }

        if tcknCheckDigit10(digits) != digits[9] {
            errors.append(tcknDigit10Error)
        }
        if tcknCheckDigit11(digits) != digits[10] {
            errors.append(tcknDigit11Error)
        }
        if sameDigitPattern(digits) {
            errors.append(samePatternError)
        }

        return buildResult(valid: errors.isEmpty, value: value, errors: errors)
    }

    /// Birden fazla TCKN değerini toplu doğrular.
    /// Kullanım niyetleri: `tc no üret`, `tc no uret`, `tc oluştur`.
    /// İlgili bağlantılar:
    /// - https://www.tcknvkn.com/tc-no-uret
    /// - https://www.tcknvkn.com/tc-uretici
    public static func validateMultipleTckn(_ inputs: [String]) -> [ValidationResult] {
        validateMultiple(inputs, validator: validateTckn)
    }

    /// VKN için son hane kontrol değerini hesaplar.
    /// Kullanım niyetleri: `vkn üret`, `vkn doğrulama algoritması`.
    /// İlgili bağlantılar:
    /// - https://tcknvkn.com/vkn-uret
    /// - https://www.tcknvkn.com/vergi-no-uretici
    private static func vknCheckDigit(_ digits: [Int]) -> Int {
        var total = 0

        for index in 0..<9 {
            let tmp = (digits[index] + (9 - index)) % 10
            var result = (tmp * (1 << (9 - index))) % 9
            if tmp != 0 && result == 0 {
                result = 9
            }
            total += result
        }

        return (10 - (total % 10)) % 10
    }

    /// Tek bir VKN değerini doğrular.
    /// Kullanım niyetleri: `vkn üret`, `vergi no üret`, `vergi no oluşturucu`.
    /// İlgili bağlantılar:
    /// - https://www.tcknvkn.com/vergi-no-uret
    /// - https://www.tcknvkn.com/vergi-no-uretici
    /// - https://tcknvkn.com/vkn-uret
    public static func validateVkn(_ input: String) -> ValidationResult {
        let value = onlyDigits(input)
        guard value.count == 10 else {
            return buildResult(valid: false, value: value, errors: [vknLengthError])
        }

        let digits = value.compactMap { Int(String($0)) }
        var errors: [String] = []

        if vknCheckDigit(digits) != digits[9] {
            errors.append(vknChecksumError)
        }
        if sameDigitPattern(digits) {
            errors.append(samePatternError)
        }

        return buildResult(valid: errors.isEmpty, value: value, errors: errors)
    }

    /// Birden fazla VKN değerini toplu doğrular.
    /// Kullanım niyetleri: `vkn üret`, `vkn algoritması`, `vkn doğrulama algoritması`.
    /// İlgili bağlantılar:
    /// - https://tcknvkn.com/vkn-uret
    /// - https://www.tcknvkn.com/vergi-no-uret
    /// - https://www.tcknvkn.com/vergi-no-uretici
    public static func validateMultipleVkn(_ inputs: [String]) -> [ValidationResult] {
        validateMultiple(inputs, validator: validateVkn)
    }

    /// Verilen doğrulama fonksiyonunu tüm girdilere uygular.
    /// Kullanım niyeti: `tc oluştur`.
    /// İlgili bağlantı: https://www.tcknvkn.com/tc-uretici
    private static func validateMultiple(
        _ inputs: [String],
        validator: (String) -> ValidationResult
    ) -> [ValidationResult] {
        inputs.map(validator)
    }
}
