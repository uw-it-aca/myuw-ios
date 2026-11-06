//
//  myuw_iosTests.swift
//  myuw-iosTests
//
//  Created by Charlon Palacay on 7/30/19.
//  Copyright © 2019 Charlon Palacay. All rights reserved.
//

import XCTest
import UIKit
@testable import MyUW

// MARK: - ID token decoding (AppAuthController)

final class IdTokenClaimsTests: XCTestCase {

    private var controller: AppAuthController!

    override func setUp() {
        super.setUp()
        controller = AppAuthController()
    }

    override func tearDown() {
        controller = nil
        super.tearDown()
    }

    /// Builds an unsigned JWT ("header.claims.signature") with base64url-style unpadded segments.
    private func makeJWT(claims: [String: Any]) throws -> String {
        func segment(_ object: [String: Any]) throws -> String {
            let data = try JSONSerialization.data(withJSONObject: object)
            return data.base64EncodedString().replacingOccurrences(of: "=", with: "")
        }
        return "\(try segment(["alg": "none", "typ": "JWT"])).\(try segment(claims)).signature"
    }

    func testPadBase64AddsPaddingToMultipleOfFour() {
        XCTAssertEqual(controller.padBase64Encoded("YQ"), "YQ==")
        XCTAssertEqual(controller.padBase64Encoded("YWI"), "YWI=")
        XCTAssertEqual(controller.padBase64Encoded("YWJj"), "YWJj")
        XCTAssertEqual(controller.padBase64Encoded(""), "")
    }

    func testPaddedStringDecodes() {
        // "a" encodes to "YQ==" ; JWTs strip the padding.
        let padded = controller.padBase64Encoded("YQ")
        XCTAssertEqual(Data(base64Encoded: padded), Data("a".utf8))
    }

    func testGetIdTokenClaimsDecodesClaims() throws {
        let token = try makeJWT(claims: ["sub": "javerage", "email": "javerage@uw.edu"])

        let data = try XCTUnwrap(controller.getIdTokenClaims(idToken: token))
        let claims = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])

        XCTAssertEqual(claims["sub"] as? String, "javerage")
        XCTAssertEqual(claims["email"] as? String, "javerage@uw.edu")
    }

    func testGetIdTokenClaimsReturnsNilForNilToken() {
        XCTAssertNil(controller.getIdTokenClaims(idToken: nil))
    }

    func testGetIdTokenClaimsReturnsNilForTokenWithoutClaimsSegment() {
        XCTAssertNil(controller.getIdTokenClaims(idToken: "onlyonesegment"))
    }

    func testGetIdTokenClaimsReturnsNilForInvalidBase64() {
        XCTAssertNil(controller.getIdTokenClaims(idToken: "header.!!!notbase64!!!.sig"))
    }
}

// MARK: - UIColor(hex:) (AppDelegate)

final class UIColorHexTests: XCTestCase {

    private func components(_ color: UIColor) -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        return (r, g, b, a)
    }

    func testParsesUWPurple() throws {
        let c = components(try XCTUnwrap(UIColor(hex: "#4b2e83")))
        XCTAssertEqual(c.r, 0x4b / 255.0, accuracy: 0.001)
        XCTAssertEqual(c.g, 0x2e / 255.0, accuracy: 0.001)
        XCTAssertEqual(c.b, 0x83 / 255.0, accuracy: 0.001)
        XCTAssertEqual(c.a, 1.0, accuracy: 0.001)
    }

    func testParsesUppercaseHex() throws {
        let c = components(try XCTUnwrap(UIColor(hex: "#FF0000")))
        XCTAssertEqual(c.r, 1.0, accuracy: 0.001)
        XCTAssertEqual(c.g, 0.0, accuracy: 0.001)
        XCTAssertEqual(c.b, 0.0, accuracy: 0.001)
    }

    func testRejectsMissingHashPrefix() {
        XCTAssertNil(UIColor(hex: "4b2e83"))
    }

    func testRejectsWrongLength() {
        XCTAssertNil(UIColor(hex: "#fff"))
        XCTAssertNil(UIColor(hex: "#4b2e83ff"))
        XCTAssertNil(UIColor(hex: "#"))
    }

    func testRejectsNonHexCharacters() {
        XCTAssertNil(UIColor(hex: "#zzzzzz"))
    }

    func testGlobalUWPurpleIsDefined() {
        XCTAssertNotNil(uwPurple)
    }
}

// MARK: - Query string parsing (WebViewController)

final class QueryStringParameterTests: XCTestCase {

    private let controller = WebViewController()

    func testReturnsValueForPresentParameter() {
        let url = "https://my.uw.edu/search?q=husky&page=2"
        XCTAssertEqual(controller.getQueryStringParameter(url: url, param: "q"), "husky")
        XCTAssertEqual(controller.getQueryStringParameter(url: url, param: "page"), "2")
    }

    func testReturnsNilForMissingParameter() {
        XCTAssertNil(controller.getQueryStringParameter(url: "https://my.uw.edu/?q=husky", param: "missing"))
    }

    func testReturnsNilWhenNoQueryString() {
        XCTAssertNil(controller.getQueryStringParameter(url: "https://my.uw.edu/", param: "q"))
    }

    func testDecodesPercentEncodedValues() {
        let url = "https://my.uw.edu/search?q=red%20square"
        XCTAssertEqual(controller.getQueryStringParameter(url: url, param: "q"), "red square")
    }

    func testReturnsFirstValueForRepeatedParameter() {
        let url = "https://my.uw.edu/?tab=home&tab=academics"
        XCTAssertEqual(controller.getQueryStringParameter(url: url, param: "tab"), "home")
    }

    func testReturnsEmptyStringForParameterWithoutValue() {
        XCTAssertEqual(controller.getQueryStringParameter(url: "https://my.uw.edu/?flag=", param: "flag"), "")
    }
}

// MARK: - Bulleted list helper (AppAuthController)

final class BulletedListTests: XCTestCase {

    func testFormatsEachItemWithBulletOnItsOwnLine() {
        let result = NSAttributedStringHelper.createBulletedList(fromStringArray: ["One", "Two", "Three"])
        XCTAssertEqual(result.string, "\u{2022} One\n\u{2022} Two\n\u{2022} Three")
    }

    func testSingleItemHasNoTrailingNewline() {
        let result = NSAttributedStringHelper.createBulletedList(fromStringArray: ["Only"])
        XCTAssertEqual(result.string, "\u{2022} Only")
    }

    func testEmptyArrayProducesEmptyString() {
        let result = NSAttributedStringHelper.createBulletedList(fromStringArray: [])
        XCTAssertEqual(result.length, 0)
    }

    func testAppliesFontAndParagraphStyle() throws {
        let font = UIFont.systemFont(ofSize: 17)
        let result = NSAttributedStringHelper.createBulletedList(fromStringArray: ["A", "B"], font: font)

        XCTAssertEqual(result.attribute(.font, at: 0, effectiveRange: nil) as? UIFont, font)

        let style = try XCTUnwrap(result.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle)
        XCTAssertEqual(style.firstLineHeadIndent, 20)
        XCTAssertEqual(style.headIndent, 31)
    }
}

// MARK: - App configuration and OAuth redirect

final class AppConfigurationTests: XCTestCase {

    private let requiredConfigKeys = [
        "oidc_issuer", "oidc_clientid", "myuw_host", "myuw_affiliation",
        "link_terms", "link_privacy", "link_eula", "link_help"
    ]

    func testBundledMyUWPlistHasAllRequiredKeys() throws {
        // AppDelegate force-casts each of these keys, so a missing key crashes at launch.
        let path = try XCTUnwrap(Bundle(for: AppDelegate.self).path(forResource: "myuw", ofType: "plist"),
                                 "myuw.plist is missing from the app bundle")
        let config = try XCTUnwrap(NSDictionary(contentsOfFile: path) as? [String: Any])

        for key in requiredConfigKeys {
            XCTAssertNotNil(config[key] as? String, "myuw.plist is missing string value for '\(key)'")
        }
    }

    func testConfigIsLoadedAtLaunch() {
        // The test host launches the app, so AppDelegate has already read myuw.plist.
        XCTAssertFalse(appHost.isEmpty)
        XCTAssertFalse(clientIssuer.isEmpty)
        XCTAssertFalse(clientID.isEmpty)
    }

    func testConfiguredURLsAreValid() {
        for (name, value) in [("myuw_host", appHost), ("oidc_issuer", clientIssuer),
                              ("link_eula", linkEULA), ("link_privacy", linkPrivacy),
                              ("link_terms", linkTerms), ("link_help", linkHelp)] {
            XCTAssertNotNil(URL(string: value)?.scheme, "\(name) is not a valid URL: \(value)")
        }
    }

    func testRedirectURISchemeIsRegisteredInInfoPlist() throws {
        let redirectScheme = try XCTUnwrap(URL(string: kRedirectURI)?.scheme)
        let urlTypes = try XCTUnwrap(Bundle(for: AppDelegate.self)
            .object(forInfoDictionaryKey: "CFBundleURLTypes") as? [[String: Any]])
        let schemes = urlTypes.flatMap { $0["CFBundleURLSchemes"] as? [String] ?? [] }

        XCTAssertTrue(schemes.contains(redirectScheme),
                      "OAuth redirect scheme '\(redirectScheme)' is not registered, so sign-in can't return to the app")
    }

    func testOpenURLWithoutPendingAuthFlowReturnsFalse() {
        let delegate = AppDelegate()
        delegate.currentAuthorizationFlow = nil

        let handled = delegate.application(UIApplication.shared, open: URL(string: kRedirectURI)!)
        XCTAssertFalse(handled)
    }
}
