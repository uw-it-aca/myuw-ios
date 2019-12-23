//
//  myuw_testUITests.swift
//  myuw-testUITests
//
//  Created by Charlon Palacay on 7/30/19.
//  Copyright © 2019 Charlon Palacay. All rights reserved.
//

import XCTest
import FBSnapshotTestCase

class myuw_testUITests: FBSnapshotTestCase {

    override func setUp() {
        super.setUp()
        recordMode = false
    }

    func testExample() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 64, height: 64))
        view.backgroundColor = UIColor.white
        FBSnapshotVerifyView(view)
        FBSnapshotVerifyLayer(view.layer)
    }
}
