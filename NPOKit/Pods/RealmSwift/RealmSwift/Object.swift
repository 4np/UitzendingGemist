////////////////////////////////////////////////////////////////////////////
//
// Copyright 2014 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////

import Foundation
import Realm
import Realm.Private

/**
 `Object` is a class used to define Realm model objects.

 In Realm you define your model classes by subclassing `Object` and adding properties to be persisted.
 You then instantiate and use your custom subclasses instead of using the `Object` class directly.

 ```swift
 class Dog: Object {
     dynamic var name: String = ""
     dynamic var adopted: Bool = false
     let siblings = List<Dog>()
 }
 ```

 ### Supported property types

 - `String`, `NSString`
 - `Int`
 - `Int8`, `Int16`, `Int32`, `Int64`
 - `Float`
 - `Double`
 - `Bool`
 - `NSDate`
 - `NSData`
 - `RealmOptional<T>` for optional numeric properties
 - `Object` subclasses, to model many-to-one relationships
 - `List<T>`, to model many-to-many relationships

 `String`, `NSString`, `NSDate`, `NSData` and `Object` subclass properties can be declared as optional. `Int`, `Int8`,
 Int16`, Int32`, `Int64`, `Float`, `Double`, `Bool`, and `List` properties cannot. To store an optional number, use
 `RealmOptional<Int>`, `RealmOptional<Float>`, `RealmOptional<Double>`, or `RealmOptional<Bool>` instead, which wraps an
 optional numeric value.

 All property types except for `List` and `RealmOptional` *must* be declared as `dynamic var`. `List` and
 `RealmOptional` properties must be declared as non-dynamic `let` properties.

 ### Querying

 You can retrieve all objects of a given type from a Realm by calling the `objects(_:)` instance method.

 ### Relationships

 See our [Cocoa guide](http://realm.io/docs/cocoa) for more details.
*/
@objc(RealmSwiftObject)
public class Object: RLMObjectBase {

    // MARK: Initializers

    /**
     Initializes an unmanaged instance of a Realm object.

     Call `add(_:)` on a `Realm` instance to add an unmanaged object into that Realm.

     - see: `Realm().add(_:)`
    */
    public override required init() {
        super.init()
    }

    /**
     Initializes an unmanaged instance of a Realm object.

     Pass in an `Array<AnyObject>` or `Dictionary<String, AnyObject>` instance to set the values of the object's
     properties, or any other valid object as described below.

     Call `add(_:)` on a `Realm` instance to add an unmanaged object into that Realm.

     - parameter value:  The value used to populate the object. This can be any key-value coding compliant
                         object, or an array or dictionary returned from the methods in `NSJSONSerialization`, or
                         an `Array` containing one element for each persisted property. An exception will be
                         thrown if any required properties are not present and those properties were not defined with
                         default values.
                         When passing in an `Array`, all properties must be present,
                         valid and in the same order as the properties defined in the model.
    */
    public init(value: AnyObject) {
        self.dynamicType.sharedSchema() // ensure this class' objectSchema is loaded in the partialSharedSchema
        super.init(value: value, schema: RLMSchema.partialSharedSchema())
    }


    // MARK: Properties

    /// The Realm which manages the object, or `nil` if the object is unmanaged.
    public var realm: Realm? {
        if let rlmReam = RLMObjectBaseRealm(self) {
            return Realm(rlmReam)
        }
        return nil
    }

    /// The object schema which lists the persisted properties for the object.
    public var objectSchema: ObjectSchema {
        return ObjectSchema(RLMObjectBaseObjectSchema(self))
    }

    /// Indicates if the object can no longer be accessed because it is now invalid.
    ///
    /// An object can no longer be accessed if the object has been deleted from the Realm that manages it, or if
    /// `invalidate` is called on that Realm.
    public override var invalidated: Bool { return super.invalidated }

    /// Returns a human-readable description of the object.
    public override var description: String { return super.description }

    #if os(OSX)
    /// A helper property that returns the class name for an `Object` subclass.
    public final override var className: String { return "" }
    #else
    /// A helper property that returns the class name for an `Object` subclass.
    public final var className: String { return "" }
    #endif

    /**
    WARNING: This is an internal helper method not intended for public use.
    :nodoc:
    */
    public override class func objectUtilClass(isSwift: Bool) -> AnyClass {
        return ObjectUtil.self
    }


    // MARK: Object Customization

    /**
     Override this method to specify the name of a property to be used as the primary key.

     Only properties of types `String` and `Int` can be designated as the primary key. Primary key properties enforce
     uniqueness for each value whenever the property is set, which incurs minor overhead. Indexes are created
     automatically for primary key properties.

     - returns: The name of the property designated as the primary key, or `nil` if the model has no primary key.
    */
    public class func primaryKey() -> String? { return nil }

    /**
     Override this method to specify the names of properties to ignore. These properties will not be persisted within
     the Realm that manages the object.

     - returns: An array of property names to ignore.
    */
    public class func ignoredProperties() -> [String] { return [] }

    /**
     Returns an array of property names for properties which should be indexed.

     Only string, integer, boolean, and `NSDate` properties are supported.

     - returns: An array of property names.
    */
    public class func indexedProperties() -> [String] { return [] }


    // MARK: Key-Value Coding & Subscripting

    /// Returns or sets the value of the property with the given name.
    public subscript(key: String) -> AnyObject? {
        get {
            if realm == nil {
                return valueForKey(key)
            }
            let property = RLMValidatedGetProperty(self, key)
            if property.type == .Array {
                return listForProperty(property)
            }
            // No special logic is needed for optional numbers here because the NSNumber returned by RLMDynamicGet
            // is better for callers than the RealmOptional that optionalForProperty would give us.
            return RLMDynamicGet(self, property)
        }
        set(value) {
            if realm == nil {
                setValue(value, forKey: key)
            } else {
                RLMDynamicValidatedSet(self, key, value)
            }
        }
    }

    // MARK: Dynamic list

    /**
     Returns a list of `DynamicObject`s for a given property name.

     - warning:  This method is useful only in specialized circumstances, for example, when building
                 components that integrate with Realm. If you are simply building an app on Realm, it is
                 recommended to use instance variables or cast the values returned from key-value coding.

    - parameter propertyName: The name of the property.

    - returns: A list of `DynamicObject`s.

    :nodoc:
    */
    public func dynamicList(propertyName: String) -> List<DynamicObject> {
        return unsafeBitCast(listForProperty(RLMValidatedGetProperty(self, propertyName)), List<DynamicObject>.self)
    }

    // MARK: Equatable

    /**
     Returns whether two Realm objects are equal.

     Objects are considered equal if and only if they are both managed by the same Realm and point to the same
     underlying object in the database.

     - parameter object: The object to compare the receiver to.
    */
    public override func isEqual(object: AnyObject?) -> Bool {
        return RLMObjectBaseAreEqual(self as RLMObjectBase?, object as? RLMObjectBase)
    }

    // MARK: Private functions

    // FIXME: None of these functions should be exposed in the public interface.

    /**
    WARNING: This is an internal initializer not intended for public use.
    :nodoc:
    */
    public override required init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }

    /**
    WARNING: This is an internal initializer not intended for public use.
    :nodoc:
    */
    public override required init(value: AnyObject, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }

    // Helper for getting the list object for a property
    internal func listForProperty(prop: RLMProperty) -> RLMListBase {
        return object_getIvar(self, prop.swiftIvar) as! RLMListBase
    }

    // Helper for getting the optional object for a property
    internal func optionalForProperty(prop: RLMProperty) -> RLMOptionalBase {
        return object_getIvar(self, prop.swiftIvar) as! RLMOptionalBase
    }

    // Helper for getting the linking objects object for a property
    internal func linkingObjectsForProperty(prop: RLMProperty) -> LinkingObjectsBase? {
        return object_getIvar(self, prop.swiftIvar) as? LinkingObjectsBase
    }
}



/// Object interface which allows untyped getters and setters for Objects.
/// :nodoc:
public final class DynamicObject: Object {
    private var listProperties = [String: List<DynamicObject>]()
    private var optionalProperties = [String: RLMOptionalBase]()

    // Override to create List<DynamicObject> on access
    internal override func listForProperty(prop: RLMProperty) -> RLMListBase {
        if let list = listProperties[prop.name] {
            return list
        }
        let list = List<DynamicObject>()
        listProperties[prop.name] = list
        return list
    }

    // Override to create RealmOptional on access
    internal override func optionalForProperty(prop: RLMProperty) -> RLMOptionalBase {
        if let optional = optionalProperties[prop.name] {
            return optional
        }
        let optional = RLMOptionalBase()
        optional.property = prop
        optionalProperties[prop.name] = optional
        return optional
    }

    // Dynamic objects never have linking objects properties
    internal override func linkingObjectsForProperty(prop: RLMProperty) -> LinkingObjectsBase? {
        return nil
    }

    /// :nodoc:
    public override func valueForUndefinedKey(key: String) -> AnyObject? {
        return self[key]
    }

    /// :nodoc:
    public override func setValue(value: AnyObject?, forUndefinedKey key: String) {
        self[key] = value
    }

    /// :nodoc:
    public override class func shouldIncludeInDefaultSchema() -> Bool {
        return false
    }
}

/// :nodoc:
/// Internal class. Do not use directly.
@objc(RealmSwiftObjectUtil)
public class ObjectUtil: NSObject {
    @objc private class func swiftVersion() -> NSString {
        return swiftLanguageVersion
    }

    @objc private class func ignoredPropertiesForClass(type: AnyClass) -> NSArray? {
        if let type = type as? Object.Type {
            return type.ignoredProperties() as NSArray?
        }
        return nil
    }

    @objc private class func indexedPropertiesForClass(type: AnyClass) -> NSArray? {
        if let type = type as? Object.Type {
            return type.indexedProperties() as NSArray?
        }
        return nil
    }

    @objc private class func linkingObjectsPropertiesForClass(type: AnyClass) -> NSDictionary? {
        // Not used for Swift. getLinkingObjectsProperties(_:) is used instead.
        return nil
    }

    // Get the names of all properties in the object which are of type List<>.
    @objc private class func getGenericListPropertyNames(object: AnyObject) -> NSArray {
        return Mirror(reflecting: object).children.filter { (prop: Mirror.Child) in
            return prop.value.dynamicType is RLMListBase.Type
        }.flatMap { (prop: Mirror.Child) in
            return prop.label
        }
    }

    @objc private class func initializeListProperty(object: RLMObjectBase, property: RLMProperty, array: RLMArray) {
        (object as! Object).listForProperty(property)._rlmArray = array
    }

    @objc private class func initializeOptionalProperty(object: RLMObjectBase, property: RLMProperty) {
        let optional = (object as! Object).optionalForProperty(property)
        optional.property = property
        optional.object = object
    }

    // swiftlint:disable:next cyclomatic_complexity
    @objc private class func getOptionalProperties(object: AnyObject) -> NSDictionary {
        let children = Mirror(reflecting: object).children
        return children.reduce([String: AnyObject]()) { ( properties: [String:AnyObject], prop: Mirror.Child) in
            guard let name = prop.label else { return properties }
            let mirror = Mirror(reflecting: prop.value)
            let type = mirror.subjectType
            var properties = properties
            if type is Optional<String>.Type || type is Optional<NSString>.Type {
                properties[name] = Int(PropertyType.String.rawValue)
            } else if type is Optional<NSDate>.Type {
                properties[name] = Int(PropertyType.Date.rawValue)
            } else if type is Optional<NSData>.Type {
                properties[name] = Int(PropertyType.Data.rawValue)
            } else if type is Optional<Object>.Type {
                properties[name] = Int(PropertyType.Object.rawValue)
            } else if type is RealmOptional<Int>.Type ||
                      type is RealmOptional<Int8>.Type ||
                      type is RealmOptional<Int16>.Type ||
                      type is RealmOptional<Int32>.Type ||
                      type is RealmOptional<Int64>.Type {
                properties[name] = Int(PropertyType.Int.rawValue)
            } else if type is RealmOptional<Float>.Type {
                properties[name] = Int(PropertyType.Float.rawValue)
            } else if type is RealmOptional<Double>.Type {
                properties[name] = Int(PropertyType.Double.rawValue)
            } else if type is RealmOptional<Bool>.Type {
                properties[name] = Int(PropertyType.Bool.rawValue)
            } else if prop.value as? RLMOptionalBase != nil {
                throwRealmException("'\(type)' is not a a valid RealmOptional type.")
            } else if mirror.displayStyle == .Optional {
                properties[name] = NSNull()
            }
            return properties
        }
    }

    @objc private class func requiredPropertiesForClass(_: AnyClass) -> NSArray? {
        return nil
    }

    // Get information about each of the linking objects properties.
    @objc private class func getLinkingObjectsProperties(object: AnyObject) -> NSDictionary {
        let properties = Mirror(reflecting: object).children.filter { (prop: Mirror.Child) in
            return prop.value as? LinkingObjectsBase != nil
        }.flatMap { (prop: Mirror.Child) in
            (prop.label!, prop.value as! LinkingObjectsBase)
        }
        return properties.reduce([:] as [String : [String: String ]]) { (dictionary, property) in
            var d = dictionary
            let (name, results) = property
            d[name] = ["class": results.objectClassName, "property": results.propertyName]
            return d
        }
    }

    @objc private class func initializeLinkingObjectsProperty(object: RLMObjectBase, property: RLMProperty) {
        guard let linkingObjects = (object as! Object).linkingObjectsForProperty(property) else { return }
        linkingObjects.attachTo(object: object, property: property)
    }
}
