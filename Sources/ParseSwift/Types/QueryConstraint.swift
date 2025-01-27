//
//  QueryConstraint.swift
//  ParseSwift
//
//  Created by Corey Baker on 12/9/21.
//  Copyright © 2021 Parse Community. All rights reserved.
//

import Foundation

/// Used to constrain a query.
public struct QueryConstraint: Encodable, Hashable {
    enum Comparator: String, CodingKey, Encodable {
        case lessThan = "$lt"
        case lessThanOrEqualTo = "$lte"
        case greaterThan = "$gt"
        case greaterThanOrEqualTo = "$gte"
        case equalTo = "$eq"
        case notEqualTo = "$ne"
        case containedIn = "$in"
        case notContainedIn = "$nin"
        case containedBy = "$containedBy"
        case exists = "$exists"
        case select = "$select"
        case dontSelect = "$dontSelect"
        case all = "$all"
        case regex = "$regex"
        case inQuery = "$inQuery"
        case notInQuery = "$notInQuery"
        case nearSphere = "$nearSphere"
        case or = "$or" //swiftlint:disable:this identifier_name
        case and = "$and"
        case nor = "$nor"
        case relatedTo = "$relatedTo"
        case within = "$within"
        case geoWithin = "$geoWithin"
        case geoIntersects = "$geoIntersects"
        case maxDistance = "$maxDistance"
        case centerSphere = "$centerSphere"
        case box = "$box"
        case polygon = "$polygon"
        case point = "$point"
        case text = "$text"
        case search = "$search"
        case term = "$term"
        case regexOptions = "$options"
        case relativeTime = "$relativeTime"
        case score = "$score"
    }

    var key: String
    var value: Encodable?
    var comparator: Comparator?
    var isNull: Bool = false

    public func encode(to encoder: Encoder) throws {
        if isNull {
            var container = encoder.singleValueContainer()
            try container.encodeNil()
        } else if let value = value as? Date {
            // Parse uses special case for date
            try value.parseRepresentation.encode(to: encoder)
        } else {
            try value?.encode(to: encoder)
        }
    }

    public static func == (lhs: QueryConstraint, rhs: QueryConstraint) -> Bool {
        guard lhs.key == rhs.key,
              lhs.comparator == rhs.comparator,
              lhs.isNull == rhs.isNull else {
            return false
        }
        guard let lhsValue = lhs.value,
              let rhsValue = rhs.value else {
                  guard lhs.value == nil,
                        rhs.value == nil else {
                      return false
                  }
                  return true
              }
        return lhsValue.isEqual(rhsValue)
    }

    public func hash(into hasher: inout Hasher) {
        do {
            let encodedData = try ParseCoding.jsonEncoder().encode(self)
            hasher.combine(encodedData)
        } catch {
            hasher.combine(0)
        }
    }
}

/**
 Add a constraint that requires that a key is greater than a value.
 - parameter key: The key that the value is stored in.
 - parameter value: The value to compare.
 - returns: The same instance of `QueryConstraint` as the receiver.
 */
public func > <T>(key: String, value: T) -> QueryConstraint where T: Encodable {
    QueryConstraint(key: key, value: value, comparator: .greaterThan)
}

/**
 Add a constraint that requires that a key is greater than or equal to a value.
 - parameter key: The key that the value is stored in.
 - parameter value: The value to compare.
 - returns: The same instance of `QueryConstraint` as the receiver.
 */
public func >= <T>(key: String, value: T) -> QueryConstraint where T: Encodable {
    QueryConstraint(key: key, value: value, comparator: .greaterThanOrEqualTo)
}

/**
 Add a constraint that requires that a key is less than a value.
 - parameter key: The key that the value is stored in.
 - parameter value: The value to compare.
 - returns: The same instance of `QueryConstraint` as the receiver.
 */
public func < <T>(key: String, value: T) -> QueryConstraint where T: Encodable {
    QueryConstraint(key: key, value: value, comparator: .lessThan)
}

/**
 Add a constraint that requires that a key is less than or equal to a value.
 - parameter key: The key that the value is stored in.
 - parameter value: The value to compare.
 - returns: The same instance of `QueryConstraint` as the receiver.
 */
public func <= <T>(key: String, value: T) -> QueryConstraint where T: Encodable {
    QueryConstraint(key: key, value: value, comparator: .lessThanOrEqualTo)
}

/**
 Add a constraint that requires that a key is equal to a value.
 - parameter key: The key that the value is stored in.
 - parameter value: The value to compare.
 - returns: The same instance of `QueryConstraint` as the receiver.
 - warning: See `equalTo` for more information.
 Behavior changes based on `ParseSwift.configuration.isUsingEqualQueryConstraint`
 where isUsingEqualQueryConstraint == true is known not to work for LiveQuery on
 Parse Servers  <= 5.0.0.
 */
public func == <T>(key: String, value: T) -> QueryConstraint where T: Encodable {
    equalTo(key: key, value: value)
}

/**
 Add a constraint that requires that a key is equal to a value.
 - parameter key: The key that the value is stored in.
 - parameter value: The value to compare.
 - parameter isUsingEQ: Set to **true** to use **$eq** comparater,
 allowing for multiple `QueryConstraint`'s to be used on a single **key**.
 Setting to *false* may override any `QueryConstraint`'s on the same **key**.
 Defaults to `ParseSwift.configuration.isUsingEqualQueryConstraint`.
 - returns: The same instance of `QueryConstraint` as the receiver.
 - warning: `isUsingEQ == true` is known not to work for LiveQueries
 on Parse Servers <= 5.0.0.
 */
public func equalTo <T>(key: String,
                        value: T,
                        //swiftlint:disable:next line_length
                        isUsingEQ: Bool = ParseSwift.configuration.isUsingEqualQueryConstraint) -> QueryConstraint where T: Encodable {
    if !isUsingEQ {
        return QueryConstraint(key: key, value: value)
    } else {
        return QueryConstraint(key: key, value: value, comparator: .equalTo)
    }
}

/**
 Add a constraint that requires that a key is equal to a `ParseObject`.
 - parameter key: The key that the value is stored in.
 - parameter value: The `ParseObject` to compare.
 - returns: The same instance of `QueryConstraint` as the receiver.
 - throws: An error of type `ParseError`.
 - warning: See `equalTo` for more information.
 Behavior changes based on `ParseSwift.configuration.isUsingEqualQueryConstraint`
 where isUsingEqualQueryConstraint == true is known not to work for LiveQuery on
 Parse Servers  <= 5.0.0.
 */
public func == <T>(key: String, value: T) throws -> QueryConstraint where T: ParseObject {
    try equalTo(key: key, value: value)
}

/**
 Add a constraint that requires that a key is equal to a `ParseObject`.
 - parameter key: The key that the value is stored in.
 - parameter value: The `ParseObject` to compare.
 - parameter isUsingEQ: Set to **true** to use **$eq** comparater,
 allowing for multiple `QueryConstraint`'s to be used on a single **key**.
 Setting to *false* may override any `QueryConstraint`'s on the same **key**.
 Defaults to `ParseSwift.configuration.isUsingEqualQueryConstraint`.
 - returns: The same instance of `QueryConstraint` as the receiver.
 - throws: An error of type `ParseError`.
 - warning: `isUsingEQ == true` is known not to work for LiveQueries
 on Parse Servers <= 5.0.0.
 */
public func equalTo <T>(key: String,
                        value: T,
                        //swiftlint:disable:next line_length
                        isUsingEQ: Bool = ParseSwift.configuration.isUsingEqualQueryConstraint) throws -> QueryConstraint where T: ParseObject {
    if !isUsingEQ {
        return try QueryConstraint(key: key, value: value.toPointer())
    } else {
        return try QueryConstraint(key: key, value: value.toPointer(), comparator: .equalTo)
    }
}

/**
 Add a constraint that requires that a key is not equal to a value.
 - parameter key: The key that the value is stored in.
 - parameter value: The value to compare.
 - returns: The same instance of `QueryConstraint` as the receiver.
 */
public func != <T>(key: String, value: T) -> QueryConstraint where T: Encodable {
    QueryConstraint(key: key, value: value, comparator: .notEqualTo)
}

/**
 Add a constraint that requires that a key is not equal to a `ParseObject`.
 - parameter key: The key that the value is stored in.
 - parameter value: The `ParseObject` to compare.
 - returns: The same instance of `QueryConstraint` as the receiver.
 */
public func != <T>(key: String, value: T) throws -> QueryConstraint where T: ParseObject {
    try QueryConstraint(key: key, value: value.toPointer(), comparator: .notEqualTo)
}

internal struct InQuery<T>: Encodable where T: ParseObject {
    let query: Query<T>
    var className: String {
        return T.className
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(className, forKey: .className)
        try container.encode(query.where, forKey: .where)
    }

    enum CodingKeys: String, CodingKey {
        case `where`, className
    }
}

internal struct OrAndQuery<T>: Encodable where T: ParseObject {
    let query: Query<T>

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(query.where)
    }

    enum CodingKeys: String, CodingKey {
        case `where`
    }
}

internal struct QuerySelect<T>: Encodable where T: ParseObject {
    let query: InQuery<T>
    let key: String
}

/**
  Returns a `Query` that is the `or` of the passed in queries.
  - parameter queries: The list of queries to `or` together.
  - returns: An instance of `QueryConstraint`'s that are the `or` of the passed in queries.
 */
public func or <T>(queries: [Query<T>]) -> QueryConstraint where T: ParseObject {
    let orQueries = queries.map { OrAndQuery(query: $0) }
    return QueryConstraint(key: QueryConstraint.Comparator.or.rawValue, value: orQueries)
}

/**
  Returns a `Query` that is the `nor` of the passed in queries.
  - parameter queries: The list of queries to `nor` together.
  - returns: An instance of `QueryConstraint`'s that are the `nor` of the passed in queries.
 */
public func nor <T>(queries: [Query<T>]) -> QueryConstraint where T: ParseObject {
    let orQueries = queries.map { OrAndQuery(query: $0) }
    return QueryConstraint(key: QueryConstraint.Comparator.nor.rawValue, value: orQueries)
}

/**
 Constructs a Query that is the `and` of the passed in queries.
 
 For example:
    
     var compoundQueryConstraints = and(query1, query2, query3)
    
 will create a compoundQuery that is an and of the query1, query2, and query3.
    - parameter queries: The list of queries to `and` together.
    - returns: An instance of `QueryConstraint`'s that are the `and` of the passed in queries.
*/
public func and <T>(queries: [Query<T>]) -> QueryConstraint where T: ParseObject {
    let andQueries = queries.map { OrAndQuery(query: $0) }
    return QueryConstraint(key: QueryConstraint.Comparator.and.rawValue, value: andQueries)
}

/**
 Add a constraint that requires that a key's value matches a `Query` constraint.
 - warning: This only works where the key's values are `ParseObject`s or arrays of `ParseObject`s.
 - parameter key: The key that the value is stored in.
 - parameter query: The query the value should match.
 - returns: The same instance of `QueryConstraint` as the receiver.
 */
public func == <T>(key: String, value: Query<T>) -> QueryConstraint {
    QueryConstraint(key: key, value: InQuery(query: value), comparator: .inQuery)
}

/**
 Add a constraint that requires that a key's value do not match a `Query` constraint.
 - warning: This only works where the key's values are `ParseObject`s or arrays of `ParseObject`s.
 - parameter key: The key that the value is stored in.
 - parameter query: The query the value should not match.
 - returns: The same instance of `QueryConstraint` as the receiver.
 */
public func != <T>(key: String, query: Query<T>) -> QueryConstraint {
    QueryConstraint(key: key, value: InQuery(query: query), comparator: .notInQuery)
}

/**
 Adds a constraint that requires that a key's value matches a value in another key
 in objects returned by a sub query.
 - parameter key: The key that contains the value that is being matched.
 - parameter queryKey: The key in objects in the returned by the sub query whose value should match.
 - parameter query: The query to run.
 - returns: The same instance of `QueryConstraint` as the receiver.
 */
public func matchesKeyInQuery <T>(key: String, queryKey: String, query: Query<T>) -> QueryConstraint {
    let select = QuerySelect(query: InQuery(query: query), key: queryKey)
    return QueryConstraint(key: key, value: select, comparator: .select)
}

/**
 Adds a constraint that requires that a key's value *not* match a value in another key
 in objects returned by a sub query.
 - parameter key: The key that contains the value that is being excluded.
 - parameter queryKey: The key in objects returned by the sub query whose value should match.
 - parameter query: The query to run.
 - returns: The same instance of `QueryConstraint` as the receiver.
 */
public func doesNotMatchKeyInQuery <T>(key: String, queryKey: String, query: Query<T>) -> QueryConstraint {
    let select = QuerySelect(query: InQuery(query: query), key: queryKey)
    return QueryConstraint(key: key, value: select, comparator: .dontSelect)
}

/**
  Add a constraint to the query that requires a particular key's object
  to be contained in the provided array.
  - parameter key: The key to be constrained.
  - parameter array: The possible values for the key's object.
  - returns: The same instance of `QueryConstraint` as the receiver.
 */
public func containedIn <T>(key: String, array: [T]) -> QueryConstraint where T: Encodable {
    QueryConstraint(key: key, value: array, comparator: .containedIn)
}

/**
  Add a constraint to the query that requires a particular key's object
  to be contained in the provided array of `ParseObjects`.
  - parameter key: The key to be constrained.
  - parameter array: The possible values for the key's object.
  - returns: The same instance of `QueryConstraint` as the receiver.
 */
public func containedIn <T>(key: String, array: [T]) throws -> QueryConstraint where T: ParseObject {
    let pointers = try array.map { try $0.toPointer() }
    return containedIn(key: key, array: pointers)
}

/**
  Add a constraint to the query that requires a particular key's object
  not be contained in the provided array.
  - parameter key: The key to be constrained.
  - parameter array: The list of values the key's object should not be.
  - returns: The same instance of `QueryConstraint` as the receiver.
 */
public func notContainedIn <T>(key: String, array: [T]) -> QueryConstraint where T: Encodable {
    QueryConstraint(key: key, value: array, comparator: .notContainedIn)
}

/**
  Add a constraint to the query that requires a particular key's object
  not be contained in the provided array of `ParseObject` pointers.
  - parameter key: The key to be constrained.
  - parameter array: The list of values the key's object should not be.
  - returns: The same instance of `QueryConstraint` as the receiver.
 */
public func notContainedIn <T>(key: String, array: [T]) throws -> QueryConstraint where T: ParseObject {
    let pointers = try array.map { try $0.toPointer() }
    return notContainedIn(key: key, array: pointers)
}

/**
  Add a constraint to the query that requires a particular key's array
  contains every element of the provided array.
  - parameter key: The key to be constrained.
  - parameter array: The possible values for the key's object.
  - returns: The same instance of `QueryConstraint` as the receiver.
 */
public func containsAll <T>(key: String, array: [T]) -> QueryConstraint where T: Encodable {
    QueryConstraint(key: key, value: array, comparator: .all)
}

/**
  Add a constraint to the query that requires a particular key's array
  contains every element of the provided array of `ParseObject's.
  - parameter key: The key to be constrained.
  - parameter array: The possible values for the key's object.
  - returns: The same instance of `QueryConstraint` as the receiver.
 */
public func containsAll <T>(key: String, array: [T]) throws -> QueryConstraint where T: ParseObject {
    let pointers = try array.map { try $0.toPointer() }
    return containsAll(key: key, array: pointers)
}

/**
  Add a constraint to the query that requires a particular key's object
  to be contained by the provided array. Get objects where all array elements match.
  - parameter key: The key to be constrained.
  - parameter array: The possible values for the key's object.
  - returns: The same instance of `QueryConstraint` as the receiver.
 */
public func containedBy <T>(key: String, array: [T]) -> QueryConstraint where T: Encodable {
    QueryConstraint(key: key, value: array, comparator: .containedBy)
}

/**
 Add a constraint to the query that requires a particular key's object
 to be contained by the provided array of `ParseObject`'s.
 Get objects where all array elements match.
  - parameter key: The key to be constrained.
  - parameter array: The possible values for the key's object.
  - returns: The same instance of `QueryConstraint` as the receiver.
 */
public func containedBy <T>(key: String, array: [T]) throws -> QueryConstraint where T: ParseObject {
    let pointers = try array.map { try $0.toPointer() }
    return containedBy(key: key, array: pointers)
}

/**
 Add a constraint to the query that requires a particular key's time is related to a specified time.
 
 For example:

     let queryRelative = GameScore.query(relative("createdAt" < "12 days ago"))

 will create a relative query where `createdAt` is less than 12 days ago.
 - parameter constraint: The key to be constrained. Should be a Date field. The value is a
 reference time, e.g. "12 days ago". Currently only comparators supported are: <, <=, >, and >=.
 - returns: The same instance of `QueryConstraint` as the receiver.
 - warning: Requires Parse Server 2.6.5+ for MongoDB and Parse Server 5.0.0+ for PostgreSQL.
 */
public func relative(_ constraint: QueryConstraint) -> QueryConstraint {
    QueryConstraint(key: constraint.key,
                    value: [QueryConstraint.Comparator.relativeTime.rawValue: AnyEncodable(constraint.value)],
                    comparator: constraint.comparator)
}

/**
 Add a constraint to the query that requires a particular key's coordinates (specified via `ParseGeoPoint`)
 be near a reference point. Distance is calculated based on angular distance on a sphere. Results will be sorted
 by distance from reference point.
 - parameter key: The key to be constrained.
 - parameter geoPoint: The reference point represented as a `ParseGeoPoint`.
 - returns: The same instance of `QueryConstraint` as the receiver.
 */
public func near(key: String, geoPoint: ParseGeoPoint) -> QueryConstraint {
    QueryConstraint(key: key, value: geoPoint, comparator: .nearSphere)
}

/**
 Add a constraint to the query that requires a particular key's coordinates (specified via `ParseGeoPoint`) be near
 a reference point and within the maximum distance specified (in radians). Distance is calculated based on
 angular distance on a sphere. Results will be sorted by distance (nearest to farthest) from the reference point.
 - parameter key: The key to be constrained.
 - parameter geoPoint: The reference point as a `ParseGeoPoint`.
 - parameter distance: Maximum distance in radians.
 - parameter sorted: `true` if results should be sorted by distance ascending, `false` is no sorting is required.
 Defaults to true.
 - returns: The same instance of `QueryConstraint` as the receiver.
 */
public func withinRadians(key: String,
                          geoPoint: ParseGeoPoint,
                          distance: Double,
                          sorted: Bool = true) -> [QueryConstraint] {
    if sorted {
        var constraints = [QueryConstraint(key: key, value: geoPoint, comparator: .nearSphere)]
        constraints.append(.init(key: key, value: distance, comparator: .maxDistance))
        return constraints
    } else {
        var constraints = [QueryConstraint(key: key, value: geoPoint, comparator: .centerSphere)]
        constraints.append(.init(key: key, value: distance, comparator: .geoWithin))
        return constraints
    }
}

/**
 Add a constraint to the query that requires a particular key's coordinates (specified via `ParseGeoPoint`)
 be near a reference point and within the maximum distance specified (in miles). Distance is calculated based
 on a spherical coordinate system. Results will be sorted by distance (nearest to farthest) from the reference point.
 - parameter key: The key to be constrained.
 - parameter geoPoint: The reference point represented as a `ParseGeoPoint`.
 - parameter distance: Maximum distance in miles.
 - parameter sorted: `true` if results should be sorted by distance ascending, `false` is no sorting is required.
 Defaults to true.
 - returns: The same instance of `QueryConstraint` as the receiver.
 */
public func withinMiles(key: String,
                        geoPoint: ParseGeoPoint,
                        distance: Double,
                        sorted: Bool = true) -> [QueryConstraint] {
    withinRadians(key: key,
                  geoPoint: geoPoint,
                  distance: (distance / ParseGeoPoint.earthRadiusMiles),
                  sorted: sorted)
}

/**
 Add a constraint to the query that requires a particular key's coordinates (specified via `ParseGeoPoint`)
 be near a reference point and within the maximum distance specified (in kilometers). Distance is calculated based
 on a spherical coordinate system. Results will be sorted by distance (nearest to farthest) from the reference point.
 - parameter key: The key to be constrained.
 - parameter geoPoint: The reference point represented as a `ParseGeoPoint`.
 - parameter distance: Maximum distance in kilometers.
 - parameter sorted: `true` if results should be sorted by distance ascending, `false` is no sorting is required.
 Defaults to true.
 - returns: The same instance of `QueryConstraint` as the receiver.
 */
public func withinKilometers(key: String,
                             geoPoint: ParseGeoPoint,
                             distance: Double,
                             sorted: Bool = true) -> [QueryConstraint] {
    withinRadians(key: key,
                  geoPoint: geoPoint,
                  distance: (distance / ParseGeoPoint.earthRadiusKilometers),
                  sorted: sorted)
}

/**
 Add a constraint to the query that requires a particular key's coordinates (specified via `ParseGeoPoint`) be
 contained within a given rectangular geographic bounding box.
 - parameter key: The key to be constrained.
 - parameter fromSouthWest: The lower-left inclusive corner of the box.
 - parameter toNortheast: The upper-right inclusive corner of the box.
 - returns: The same instance of `QueryConstraint` as the receiver.
 */
public func withinGeoBox(key: String, fromSouthWest southwest: ParseGeoPoint,
                         toNortheast northeast: ParseGeoPoint) -> QueryConstraint {
    let array = [southwest, northeast]
    let dictionary = [QueryConstraint.Comparator.box.rawValue: array]
    return .init(key: key, value: dictionary, comparator: .within)
}

/**
 Add a constraint to the query that requires a particular key's
 coordinates be contained within and on the bounds of a given polygon
 Supports closed and open (last point is connected to first) paths.

 Polygon must have at least 3 points.

 - parameter key: The key to be constrained.
 - parameter points: The polygon points as an Array of `ParseGeoPoint`'s.
 - warning: Requires Parse Server 2.5.0+.
 - returns: The same instance of `QueryConstraint` as the receiver.
 */
public func withinPolygon(key: String, points: [ParseGeoPoint]) -> QueryConstraint {
    let polygon = points.flatMap { [[$0.latitude, $0.longitude]]}
    let dictionary = [QueryConstraint.Comparator.polygon.rawValue: polygon]
    return .init(key: key, value: dictionary, comparator: .geoWithin)
}

/**
 Add a constraint to the query that requires a particular key's
 coordinates be contained within and on the bounds of a given polygon
 Supports closed and open (last point is connected to first) paths.

 - parameter key: The key to be constrained.
 - parameter polygon: The `ParsePolygon`.
 - warning: Requires Parse Server 2.5.0+.
 - returns: The same instance of `QueryConstraint` as the receiver.
 */
public func withinPolygon(key: String, polygon: ParsePolygon) -> QueryConstraint {
    let polygon = polygon.coordinates.flatMap { [[$0.latitude, $0.longitude]]}
    let dictionary = [QueryConstraint.Comparator.polygon.rawValue: polygon]
    return .init(key: key, value: dictionary, comparator: .geoWithin)
}

/**
 Add a constraint to the query that requires a particular key's
 coordinates contains a `ParseGeoPoint`.

 - parameter key: The key of the `ParsePolygon`.
 - parameter point: The `ParseGeoPoint` to check for containment.
 - warning: Requires Parse Server 2.6.0+.
 - returns: The same instance of `QueryConstraint` as the receiver.
 */
public func polygonContains(key: String, point: ParseGeoPoint) -> QueryConstraint {
    let dictionary = [QueryConstraint.Comparator.point.rawValue: point]
    return .init(key: key, value: dictionary, comparator: .geoIntersects)
}

/**
  Add a constraint for finding string values that contain a provided
  string using Full Text Search.
  - parameter key: The key to be constrained.
  - parameter text: The substring that the value must contain.
  - returns: The resulting `QueryConstraint`.
  - note: In order to sort you must use `Query.sortByTextScore()`.
    To retrieve the weight/rank, access the "score" property of your `ParseObject`.
  - warning: This may be slow for large datasets. Requires Parse Server > 2.5.0.
 */
public func matchesText(key: String, text: String) -> QueryConstraint {
    let dictionary = [QueryConstraint.Comparator.search.rawValue: [QueryConstraint.Comparator.term.rawValue: text]]
    return .init(key: key, value: dictionary, comparator: .text)
}

/**
  Options used to constrain a text search.
 */
public enum ParseTextOption: String {
    /// The language that determines the list of stop words for the search and the rules for the stemmer and tokenizer.
    /// Must be of type `String`.
    case language = "$language"
    /// A boolean flag to enable or disable case sensitive search.
    case caseSensitive = "$caseSensitive"
    /// A boolean flag to enable or disable diacritic sensitive search.
    case diacriticSensitive = "$diacriticSensitive"

    internal func buildSearch(_ text: String,
                              options: [Self: Encodable]) throws -> [String: Encodable] {
        var dictionary: [String: Encodable] = [QueryConstraint.Comparator.term.rawValue: text]
        for (key, value) in options {
            switch key {
            case .language:
                guard (value as? String) != nil else {
                    throw ParseError(code: .unknownError,
                                     message: "Text option \(key) has to be a String")
                }
                dictionary[key.rawValue] = value
            case .caseSensitive, .diacriticSensitive:
                guard (value as? Bool) != nil else {
                    throw ParseError(code: .unknownError,
                                     message: "Text option \(key) has to be a Bool")
                }
                dictionary[key.rawValue] = value
            }
        }
        return dictionary
    }
}

/**
  Add a constraint for finding string values that contain a provided
  string using Full Text Search.
  - parameter key: The key to be constrained.
  - parameter text: The substring that the value must contain.
  - parameter options: The dictionary of options to constrain the search.
     The key is of type `TextOption` and must have a respective value.
  - returns: The resulting `QueryConstraint`.
  - note: In order to sort you must use `Query.sortByTextScore()`.
    To retrieve the weight/rank, access the "score" property of your `ParseObject`.
  - warning: This may be slow for large datasets. Requires Parse Server > 2.5.0.
 */
public func matchesText(key: String,
                        text: String,
                        options: [ParseTextOption: Encodable]) throws -> QueryConstraint {
    let search = try ParseTextOption.language.buildSearch(text, options: options)
    let dictionary = [QueryConstraint.Comparator.search.rawValue: search]
    return .init(key: key, value: AnyEncodable(dictionary), comparator: .text)
}

/**
  Add a regular expression constraint for finding string values that match the provided regular expression.
  - warning: This may be slow for large datasets.
  - parameter key: The key that the string to match is stored in.
  - parameter regex: The regular expression pattern to match.
  - parameter modifiers: Any of the following supported PCRE modifiers (defaults to nil):
  - `i` - Case insensitive search
  - `m` - Search across multiple lines of input
  - returns: The resulting `QueryConstraint`.
 */
public func matchesRegex(key: String, regex: String, modifiers: String? = nil) -> QueryConstraint {

    if let modifiers = modifiers {
        let dictionary = [
            QueryConstraint.Comparator.regex.rawValue: regex,
            QueryConstraint.Comparator.regexOptions.rawValue: modifiers
        ]
        return .init(key: key, value: dictionary)
    } else {
        return .init(key: key, value: regex, comparator: .regex)
    }
}

private func regexStringForString(_ inputString: String) -> String {
    let escapedString = inputString.replacingOccurrences(of: "\\E", with: "\\E\\\\E\\Q")
    return "\\Q\(escapedString)\\E"
}

/**
  Add a constraint for finding string values that contain a provided substring.
  - warning: This will be slow for large datasets.
  - parameter key: The key that the string to match is stored in.
  - parameter substring: The substring that the value must contain.
  - parameter modifiers: Any of the following supported PCRE modifiers (defaults to nil):
    - `i` - Case insensitive search
    - `m` - Search across multiple lines of input
  - returns: The resulting `QueryConstraint`.
 */
public func containsString(key: String, substring: String, modifiers: String? = nil) -> QueryConstraint {
    let regex = regexStringForString(substring)
    return matchesRegex(key: key, regex: regex, modifiers: modifiers)
}

/**
  Add a constraint for finding string values that start with a provided prefix.
  This will use smart indexing, so it will be fast for large datasets.
  - parameter key: The key that the string to match is stored in.
  - parameter prefix: The substring that the value must start with.
  - parameter modifiers: Any of the following supported PCRE modifiers (defaults to nil):
    - `i` - Case insensitive search
    - `m` - Search across multiple lines of input
  - returns: The resulting `QueryConstraint`.
 */
public func hasPrefix(key: String, prefix: String, modifiers: String? = nil) -> QueryConstraint {
    let regex = "^\(regexStringForString(prefix))"
    return matchesRegex(key: key, regex: regex, modifiers: modifiers)
}

/**
  Add a constraint for finding string values that end with a provided suffix.
  - warning: This will be slow for large datasets.
  - parameter key: The key that the string to match is stored in.
  - parameter suffix: The substring that the value must end with.
  - parameter modifiers: Any of the following supported PCRE modifiers (defaults to nil):
    - `i` - Case insensitive search
    - `m` - Search across multiple lines of input
  - returns: The resulting `QueryConstraint`.
 */
public func hasSuffix(key: String, suffix: String, modifiers: String? = nil) -> QueryConstraint {
    let regex = "\(regexStringForString(suffix))$"
    return matchesRegex(key: key, regex: regex, modifiers: modifiers)
}

/**
 Add a constraint that requires that a key is equal to **null** or **undefined**.
 - parameter key: The key that the value is stored in.
 - returns: The same instance of `QueryConstraint` as the receiver.
 */
public func isNull (key: String) -> QueryConstraint {
    QueryConstraint(key: key, isNull: true)
}

/**
 Add a constraint that requires that a key is not equal to **null** or **undefined**.
 - parameter key: The key that the value is stored in.
 - returns: The same instance of `QueryConstraint` as the receiver.
 */
public func isNotNull (key: String) -> QueryConstraint {
    QueryConstraint(key: key, comparator: .notEqualTo, isNull: true)
}

/**
  Add a constraint that requires a particular key to be equal to **undefined**.
  - parameter key: The key that should exist.
  - returns: The resulting `QueryConstraint`.
 */
public func exists(key: String) -> QueryConstraint {
    .init(key: key, value: true, comparator: .exists)
}

/**
  Add a constraint that requires a key  to not be equal to **undefined**.
  - parameter key: The key that should not exist.
  - returns: The resulting `QueryConstraint`.
 */
public func doesNotExist(key: String) -> QueryConstraint {
    .init(key: key, value: false, comparator: .exists)
}

internal struct RelatedKeyCondition: Encodable {
    let key: String
}

internal struct RelatedObjectCondition <T>: Encodable where T: ParseObject {
    let object: Pointer<T>
}

internal struct RelatedCondition <T>: Encodable where T: ParseObject {
    let object: Pointer<T>
    let key: String
}

/**
  Add a constraint that requires a key is related.
  - parameter key: The key that should be related.
  - parameter object: The object that should be related.
  - returns: The resulting `QueryConstraint`.
  - throws: An error of type `ParseError`.
 */
public func related <T>(key: String, object: T) throws -> QueryConstraint where T: ParseObject {
    let pointer = try object.toPointer()
    let condition = RelatedCondition(object: pointer, key: key)
    return .init(key: QueryConstraint.Comparator.relatedTo.rawValue, value: condition)
}

/**
  Add a constraint that requires a key is related.
  - parameter key: The key that should be related.
  - parameter object: The pointer object that should be related.
  - returns: The resulting `QueryConstraint`.
 */
public func related <T>(key: String, object: Pointer<T>) -> QueryConstraint where T: ParseObject {
    let condition = RelatedCondition(object: object, key: key)
    return .init(key: QueryConstraint.Comparator.relatedTo.rawValue, value: condition)
}

/**
  Add a constraint that requires a key is related.
  - parameter key: The key that should be related.
  - returns: The resulting `QueryConstraint`.
  - throws: An error of type `ParseError`.
 */
public func related(key: String) -> QueryConstraint {
    let condition = RelatedKeyCondition(key: key)
    return .init(key: QueryConstraint.Comparator.relatedTo.rawValue, value: condition)
}

/**
  Add a constraint that requires a key is related.
  - parameter object: The object that should be related.
  - returns: The resulting `QueryConstraint`.
  - throws: An error of type `ParseError`.
 */
public func related <T>(object: T) throws -> QueryConstraint where T: ParseObject {
    let pointer = try object.toPointer()
    let condition = RelatedObjectCondition(object: pointer)
    return .init(key: QueryConstraint.Comparator.relatedTo.rawValue, value: condition)
}

/**
  Add a constraint that requires a key is related.
  - parameter object: The pointer object that should be related.
  - returns: The resulting `QueryConstraint`.
 */
public func related <T>(object: Pointer<T>) -> QueryConstraint where T: ParseObject {
    let condition = RelatedObjectCondition(object: object)
    return .init(key: QueryConstraint.Comparator.relatedTo.rawValue, value: condition)
}
