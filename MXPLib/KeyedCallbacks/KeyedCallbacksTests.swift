//
//  KeyedCallbacksTests.swift
//  MXPLib
//
//  Created by Kassem Wridan on 02/08/2015.
//  Copyright © 2015 Kassem Wridan. All rights reserved.
//

import XCTest

@testable import MXPLib

// MARK: Helper classes

class CallbacksTestScope
{
    var handles = [CallbackHandle]()
}

class CallbacksTestHelper<CallbackParameters>
{
    var keyedCallbacks = KeyedCallbacks<CallbackParameters>()
    var defaultScope = CallbacksTestScope()

    func addCallback(key: String, callback: KeyedCallbacks<CallbackParameters>.Callback)
    {
        addCallback(key, scope: defaultScope, callback: callback)
    }
    
    func addCallback(key: String, scope: CallbacksTestScope, callback: KeyedCallbacks<CallbackParameters>.Callback)
    {
        scope.handles.append(keyedCallbacks.register(key, callback: callback))
    }
    
    func triggerCallbacks(forKey key:String, withParameters parameters: CallbackParameters)
    {
        keyedCallbacks.performCallbacksForKey(key, withParameters: parameters)
    }
    
    func numberOfCallbacksForKey(key:String) -> Int
    {
        return keyedCallbacks.callbacksForKey(key).count
    }
}

func localScope(code: () -> ()) {
    code()
}

func localScope2(code: (scope: CallbacksTestScope) -> ()) {
    let scope = CallbacksTestScope()
    code(scope: scope)
}

// MARK: -

class KeyedCallbacksTests: XCTestCase {

    var testHelper : CallbacksTestHelper<Void>!
    
    override func setUp()
    {
        super.setUp()
        
        testHelper = CallbacksTestHelper()
    }
    
    // MARK: Test Helpers
    
    func addCallback(key: String, callback: KeyedCallbacks<Void>.Callback)
    {
        testHelper.addCallback(key, callback: callback)
    }
    
    func addCallback(key: String, scope: CallbacksTestScope, callback: KeyedCallbacks<Void>.Callback)
    {
        testHelper.addCallback(key, scope: scope, callback: callback)
    }
    
    func triggerCallbacks(forKey key:String)
    {
        testHelper.triggerCallbacks(forKey: key, withParameters: ())
    }
    
    func verifyCallbacksCountEquals(size: Int, forKey key:String)
    {
        XCTAssertEqual(testHelper.numberOfCallbacksForKey(key), size)
    }
    
    // MARK: Tests
    
    func testAddingCallbacks()
    {
        verifyCallbacksCountEquals(0, forKey: "key1")
        verifyCallbacksCountEquals(0, forKey: "key2")
        verifyCallbacksCountEquals(0, forKey: "key3")
        
        addCallback("key1", callback: {})
        addCallback("key1", callback: {})
        
        addCallback("key2", callback: {})
        
        verifyCallbacksCountEquals(2, forKey: "key1")
        verifyCallbacksCountEquals(1, forKey: "key2")
        verifyCallbacksCountEquals(0, forKey: "key3")
    }
    
    func testCallbacks()
    {
        let expectation1 = expectationWithDescription("callback1 should be called")
        let expectation2 = expectationWithDescription("callback2 should be called")
        
        addCallback("key1") {
            expectation1.fulfill()
        }
        
        addCallback("key1") {
            expectation2.fulfill()
        }
        
        addCallback("key2") {
            XCTFail("key2 callback shouldn't be called")
        }
        
        triggerCallbacks(forKey: "key1")
        
        self.waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testCallbackCountWhenDescoping()
    {
        verifyCallbacksCountEquals(0, forKey: "key1")
        
        addCallback("key1", callback: {})
        
        verifyCallbacksCountEquals(1, forKey: "key1")
        
        localScope2 { scope in
            self.addCallback("key1", scope: scope, callback: {})
            self.verifyCallbacksCountEquals(2, forKey: "key1")
        }
        
        verifyCallbacksCountEquals(1, forKey: "key1")
    }

}

// MARK: -

class ParameterisedKeyedCallbacksTests: XCTestCase
{
    var testHelper : CallbacksTestHelper<String>!
    
    override func setUp()
    {
        super.setUp()
        
        testHelper = CallbacksTestHelper()
    }
    
    // MARK: Test Helpers
    
    func addCallback(key: String, callback: KeyedCallbacks<String>.Callback)
    {
        testHelper.addCallback(key, callback: callback)
    }
    
    func addCallback(key: String, scope: CallbacksTestScope, callback: KeyedCallbacks<String>.Callback)
    {
        testHelper.addCallback(key, scope: scope, callback: callback)
    }
    
    func triggerCallbacks(forKey key:String, withParameters parameters: String)
    {
        testHelper.triggerCallbacks(forKey: key, withParameters: parameters)
    }
    
    func verifyCallbacksCountEquals(size: Int, forKey key:String)
    {
        XCTAssertEqual(testHelper.numberOfCallbacksForKey(key), size)
    }
    
    // MARK: Tests
    
    func testCallbacks()
    {
        let expectation1 = expectationWithDescription("callback1 should be called")
        let expectation2 = expectationWithDescription("callback2 should be called")
        let expectation3 = expectationWithDescription("callback3 should be called")
        
        let testParameters1 = "test params"
        let testParameters2 = "another test params"
        
        addCallback("key1") { str in
            XCTAssertEqual(str, testParameters1)
            expectation1.fulfill()
        }
        
        addCallback("key1") { str in
            XCTAssertEqual(str, testParameters1)
            expectation2.fulfill()
        }
        
        addCallback("key2") { str in
            XCTFail("key2 callback shouldn't be called")
        }
        
        addCallback("key3") { str in
            XCTAssertEqual(str, testParameters2)
            expectation3.fulfill()
        }
        
        triggerCallbacks(forKey: "key1", withParameters: testParameters1)
        triggerCallbacks(forKey: "key3", withParameters: testParameters2)
        
        self.waitForExpectationsWithTimeout(1, handler: nil)
    }
}
