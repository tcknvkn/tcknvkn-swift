// -----------------------------------------------------------------------------
// Proje: tcknvkn-swift
// Dosya: Tests/TcknVknTests/TcknVknTests.swift
// Açıklama: TCKN ve VKN doğrulama fonksiyonları için varyasyonlu birim testleri içerir.
// Oluşturma Tarihi: 2026-04-24
// Lisans: MIT
// Site: https://www.tcknvkn.com
// -----------------------------------------------------------------------------
import XCTest
@testable import TcknVkn

final class TcknVknTests: XCTestCase {
    /// Test için geçerli bir TCKN üretir.
    private func makeValidTckn(_ firstNine: String = "100000001") -> String {
        let digits = firstNine.compactMap { Int(String($0)) }
        let odd = digits[0] + digits[2] + digits[4] + digits[6] + digits[8]
        let even = digits[1] + digits[3] + digits[5] + digits[7]
        let d10 = ((odd * 7 - even) % 10 + 10) % 10
        let d11 = (digits.reduce(0, +) + d10) % 10
        return firstNine + String(d10) + String(d11)
    }

    /// Test için geçerli bir VKN üretir.
    private func makeValidVkn(_ firstNine: String = "100003610") -> String {
        let digits = firstNine.compactMap { Int(String($0)) }
        var total = 0

        for index in 0..<9 {
            let tmp = (digits[index] + (9 - index)) % 10
            var result = (tmp * (1 << (9 - index))) % 9
            if tmp != 0 && result == 0 {
                result = 9
            }
            total += result
        }

        let checksum = (10 - (total % 10)) % 10
        return firstNine + String(checksum)
    }

    /// Geçerli ve geçersiz TCKN senaryolarını doğrular.
    func testValidateTcknVariants() {
        let validTckn = makeValidTckn()

        let valid = TcknVkn.validateTckn(validTckn)
        XCTAssertTrue(valid.valid)
        XCTAssertEqual(valid.value, validTckn)

        let normalized = TcknVkn.validateTckn("\(validTckn.prefix(3))-\(validTckn.dropFirst(3))")
        XCTAssertTrue(normalized.valid)
        XCTAssertEqual(normalized.value, validTckn)

        let short = TcknVkn.validateTckn("12345")
        XCTAssertFalse(short.valid)
        XCTAssertTrue(short.errors.contains("11 haneli olmalıdır."))

        let leadingZero = TcknVkn.validateTckn("01234567890")
        XCTAssertFalse(leadingZero.valid)
        XCTAssertTrue(leadingZero.errors.contains("İlk hane 0 olamaz."))

        let wrong10Value = String(validTckn.prefix(9)) + "0" + String(validTckn.suffix(1))
        let wrong10 = TcknVkn.validateTckn(wrong10Value)
        XCTAssertFalse(wrong10.valid)
        XCTAssertTrue(wrong10.errors.contains("10. hane kontrol hanesi hatalı."))

        let wrong11Value = String(validTckn.dropLast()) + "0"
        let wrong11 = TcknVkn.validateTckn(wrong11Value)
        XCTAssertFalse(wrong11.valid)
        XCTAssertTrue(wrong11.errors.contains("11. hane kontrol hanesi hatalı."))

        let repeated = TcknVkn.validateTckn("11111111111")
        XCTAssertFalse(repeated.valid)
        XCTAssertTrue(repeated.errors.contains("Geçersiz örüntü: tüm haneler aynı."))
    }

    /// Geçerli ve geçersiz VKN senaryolarını doğrular.
    func testValidateVknVariants() {
        let validVkn = makeValidVkn()

        let valid = TcknVkn.validateVkn(validVkn)
        XCTAssertTrue(valid.valid)
        XCTAssertEqual(valid.value, validVkn)

        let normalized = TcknVkn.validateVkn("\(validVkn.prefix(3))-\(validVkn.dropFirst(3))")
        XCTAssertTrue(normalized.valid)
        XCTAssertEqual(normalized.value, validVkn)

        let short = TcknVkn.validateVkn("1234")
        XCTAssertFalse(short.valid)
        XCTAssertEqual(short.errors, ["10 haneli olmalıdır."])

        let wrongChecksumValue = String(validVkn.dropLast()) + "0"
        let wrong = TcknVkn.validateVkn(wrongChecksumValue)
        XCTAssertFalse(wrong.valid)
        XCTAssertTrue(wrong.errors.contains("Son hane kontrol hanesi hatalı."))

        let repeated = TcknVkn.validateVkn("1111111111")
        XCTAssertFalse(repeated.valid)
        XCTAssertTrue(repeated.errors.contains("Geçersiz örüntü: tüm haneler aynı."))
    }

    /// Kısa ve sıfırla başlayan TCKN girdisinde çoklu hata döndüğünü doğrular.
    func testValidateTcknMultipleErrors() {
        let result = TcknVkn.validateTckn("0")
        XCTAssertFalse(result.valid)
        XCTAssertTrue(result.errors.contains("11 haneli olmalıdır."))
        XCTAssertTrue(result.errors.contains("İlk hane 0 olamaz."))
    }

    /// Toplu TCKN doğrulamasında sıra bütünlüğünü doğrular.
    func testValidateMultipleTcknOrder() {
        let valid = makeValidTckn()
        let invalid = String(valid.dropLast()) + "0"

        let results = TcknVkn.validateMultipleTckn([valid, invalid, "11111111111"])
        XCTAssertEqual(results.count, 3)
        XCTAssertTrue(results[0].valid)
        XCTAssertFalse(results[1].valid)
        XCTAssertFalse(results[2].valid)
    }

    /// Toplu VKN doğrulamasında sıra bütünlüğünü doğrular.
    func testValidateMultipleVknOrder() {
        let valid = makeValidVkn()
        let invalid = String(valid.dropLast()) + "0"

        let results = TcknVkn.validateMultipleVkn([valid, invalid, "1111111111"])
        XCTAssertEqual(results.count, 3)
        XCTAssertTrue(results[0].valid)
        XCTAssertFalse(results[1].valid)
        XCTAssertFalse(results[2].valid)
    }

    /// Boş giriş listesinde toplu doğrulamanın boş sonuç döndürdüğünü doğrular.
    func testValidateMultipleWithEmptyInputs() {
        let empty: [ValidationResult] = []
        XCTAssertEqual(TcknVkn.validateMultipleTckn([]), empty)
        XCTAssertEqual(TcknVkn.validateMultipleVkn([]), empty)
    }
}
