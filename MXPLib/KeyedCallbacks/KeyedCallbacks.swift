//
//  KeyedCallbacks.swift
//  MXPLib
//
//  Created by Kassem Wridan on 02/08/2015.
//  Copyright © 2015 Kassem Wridan. All rights reserved.
//

import Foundation

// MARK: Public

/// `CallbackHandle` is an opaque type used for callback management. 
/// It controls the lifetime of a callback.
public protocol CallbackHandle
{
    
}

public class KeyedCallbacks<CallbackParameters>
{
    public typealias Callback = (CallbackParameters) -> Void
    
    private var keyedHandles = KeyedCallbackHandles<CallbackParameters>()
    
    public init()
    {
        
    }
    
    /// Callers of this method must keep a the returned `CallbackHandle` alive
    /// for as long as they require callbacks.
    ///
    /// Callbacks are automatically de-registered as soon as `CallbackHandle` is deallocated.
    public func register(key: String, callback: Callback) -> CallbackHandle
    {
        let handle = KeyedCallbackHandle<CallbackParameters>(key:key, callback:callback)
        keyedHandles.add(handle)
        return handle
    }
    
    public func performCallbacksForKey(key: String, withParameters parameters: CallbackParameters)
    {
        for callback in callbacksForKey(key)
        {
            callback(parameters)
        }
    }
    
    public func callbacksForKey(key: String) -> [Callback]
    {
        var callbacks = [Callback]()
        
        if let handles = keyedHandles.handlesForKey(key)
        {
            callbacks = handles.map({ $0.callback })
        }
        
        return callbacks
    }
    
}

// MARK: Private

private class KeyedCallbackHandle<CallbackParameters> : CallbackHandle, Equatable
{
    typealias Callback = (CallbackParameters) -> Void
    let key: String
    let callback : Callback
    var onDeinit : (()->Void)?
    
    init(key: String, callback: Callback)
    {
        self.key = key
        self.callback = callback
    }
    
    deinit
    {
        onDeinit?()
    }
}

private func ==<T>(lhs: KeyedCallbackHandle<T>, rhs: KeyedCallbackHandle<T>) -> Bool
{
    return lhs === rhs
}

// MARK: -

private class WeakKeyedCallbackHandle<CallbackParameters> : Equatable
{
    weak var handle : KeyedCallbackHandle<CallbackParameters>?
    init(_ handle: KeyedCallbackHandle<CallbackParameters>)
    {
        self.handle = handle
    }
}

private func ==<T>(lhs: WeakKeyedCallbackHandle<T>, rhs: WeakKeyedCallbackHandle<T>) -> Bool
{
    return lhs.handle == rhs.handle
}

// MARK: -

private class KeyedCallbackHandles<CallbackParameters>
{
    private var keyedHandles = [String: [WeakKeyedCallbackHandle<CallbackParameters>]]()
    
    func add(handle: KeyedCallbackHandle<CallbackParameters>)
    {
        handle.onDeinit = { [weak self, weak handle] in
            if let s = self, let h = handle
            {
                s.remove(h)
            }
        }
        let weakHandle = WeakKeyedCallbackHandle(handle)
        if var handles = keyedHandles[handle.key]
        {
            handles.append(weakHandle)
            keyedHandles[handle.key] = handles
        }
        else
        {
            keyedHandles[handle.key] = [weakHandle]
        }
    }
    
    func remove(handle: KeyedCallbackHandle<CallbackParameters>)
    {
        if var handles = keyedHandles[handle.key],
            let index = handles.indexOf(WeakKeyedCallbackHandle(handle))
        {
            handles.removeAtIndex(index)
            if handles.count > 0
            {
                keyedHandles[handle.key] = handles
            }
            else
            {
                keyedHandles.removeValueForKey(handle.key)
            }
        }
    }
    
    func handlesForKey(key: String) -> [KeyedCallbackHandle<CallbackParameters>]?
    {
        var handles : [KeyedCallbackHandle<CallbackParameters>]?
        
        if let weakHandles = keyedHandles[key]
        {
            handles = weakHandles.flatMap({ $0.handle })
        }
        
        return handles
    }
}






