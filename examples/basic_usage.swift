// -----------------------------------------------------------------------------
// Proje: tcknvkn-swift
// Dosya: examples/basic_usage.swift
// Açıklama: TCKN ve VKN doğrulama fonksiyonlarının kısa kullanım örneğini içerir.
// Oluşturma Tarihi: 2026-04-24
// Lisans: MIT
// Site: https://www.tcknvkn.com
// -----------------------------------------------------------------------------
import TcknVkn

let tcknResult = TcknVkn.validateTckn("10000000146")
print("TCKN sonucu: \(tcknResult)")

let vknResult = TcknVkn.validateVkn("1000036109")
print("VKN sonucu: \(vknResult)")

let multipleTckn = TcknVkn.validateMultipleTckn(["10000000146", "10000000145"])
print("Toplu TCKN: \(multipleTckn)")

let multipleVkn = TcknVkn.validateMultipleVkn(["1000036109", "1000036108"])
print("Toplu VKN: \(multipleVkn)")
