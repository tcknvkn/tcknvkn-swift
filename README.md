# tcknvkn (Swift)

`tcknvkn`, Swift projelerinde Türkiye Cumhuriyeti Kimlik Numarası (TCKN) ve Vergi Kimlik Numarası (VKN) doğrulaması yapmak için geliştirilmiş hafif bir kütüphanedir.

## Kurulum

`Package.swift` içine ekleyin:

```swift
dependencies: [
    .package(url: "https://github.com/tcknvkn/tcknvkn-swift.git", branch: "release")
]
```

Hedef bağımlılığı:

```swift
.target(
    name: "App",
    dependencies: [
        .product(name: "TcknVkn", package: "tcknvkn-swift")
    ]
)
```

## Hızlı Başlangıç

```swift
import TcknVkn

let tckn = TcknVkn.validateTckn("10000000146")
print(tckn.valid)

let vkn = TcknVkn.validateVkn("1000036109")
print(vkn.valid)
```

## API Özeti

- `TcknVkn.validateTckn(_ input: String) -> ValidationResult`
- `TcknVkn.validateMultipleTckn(_ inputs: [String]) -> [ValidationResult]`
- `TcknVkn.validateVkn(_ input: String) -> ValidationResult`
- `TcknVkn.validateMultipleVkn(_ inputs: [String]) -> [ValidationResult]`

## ValidationResult

```swift
public struct ValidationResult {
    public let valid: Bool
    public let value: String
    public let errors: [String]
}
```

## Sık Kullanım İfadeleri

- tc üret
- tc uret
- tc no üret
- tc no uret
- tc oluştur
- tckn üret
- vkn üret
- vergi no üret
- vergi no oluşturucu
- vkn algoritması
- vkn doğrulama algoritması

## İlgili Bağlantılar

- [Kütüphaneler](https://www.tcknvkn.com/kutuphaneler)
- [Swift kütüphane sayfası](https://www.tcknvkn.com/kutuphaneler/swift)
- [TC üret](https://www.tcknvkn.com/tc-uret)
- [TC no üret](https://www.tcknvkn.com/tc-no-uret)
- [TC üretici](https://www.tcknvkn.com/tc-uretici)
- [TCKN üret](https://tcknvkn.com/tckn-uret)
- [Vergi no üret](https://www.tcknvkn.com/vergi-no-uret)
- [Vergi no üretici](https://www.tcknvkn.com/vergi-no-uretici)
- [VKN üret](https://tcknvkn.com/vkn-uret)

## Test

```bash
swift test
```

## Lisans

MIT
