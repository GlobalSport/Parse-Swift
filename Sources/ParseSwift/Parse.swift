import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

// swiftlint:disable line_length

/// The Configuration for a Parse client.
public struct ParseConfiguration {

    /// The application id of your Parse application.
    public internal(set) var applicationId: String

    /// The master key of your Parse application.
    public internal(set) var masterKey: String? // swiftlint:disable:this inclusive_language

    /// The client key of your Parse application.
    public internal(set) var clientKey: String?

    /// The server URL to connect to Parse Server.
    public internal(set) var serverURL: URL

    /// The live query server URL to connect to Parse Server.
    public internal(set) var liveQuerysServerURL: URL?

    /// Allows objectIds to be created on the client.
    public internal(set) var isAllowingCustomObjectIds = false

    /// Use transactions when saving/updating multiple objects.
    /// - warning: This is experimental.
    public internal(set) var isUsingTransactions = false

    /// Use the **$eq** query constraint when querying.
    /// - warning: This is known not to work for LiveQuery on Parse Servers <= 5.0.0.
    public internal(set) var isUsingEqualQueryConstraint = false

    /// The default caching policy for all http requests that determines when to
    /// return a response from the cache. Defaults to `useProtocolCachePolicy`.
    /// See Apple's [documentation](https://developer.apple.com/documentation/foundation/url_loading_system/accessing_cached_data)
    /// for more info.
    public internal(set) var requestCachePolicy = URLRequest.CachePolicy.useProtocolCachePolicy

    /// A dictionary of additional headers to send with requests. See Apple's
    /// [documentation](https://developer.apple.com/documentation/foundation/urlsessionconfiguration/1411532-httpadditionalheaders)
    /// for more info.
    public internal(set) var httpAdditionalHeaders: [AnyHashable: Any]?

    /// The memory capacity of the cache, in bytes. Defaults to 512KB.
    public internal(set) var cacheMemoryCapacity = 512_000

    /// The disk capacity of the cache, in bytes. Defaults to 10MB.
    public internal(set) var cacheDiskCapacity = 10_000_000

    /// If your app previously used the iOS Objective-C SDK, setting this value
    /// to `true` will attempt to migrate relevant data stored in the Keychain to
    /// ParseSwift. Defaults to `false`.
    public internal(set) var isMigratingFromObjcSDK: Bool = false

    /// Deletes the Parse Keychain when the app is running for the first time.
    /// Defaults to `false`.
    public internal(set) var isDeletingKeychainIfNeeded: Bool = false

    /// Maximum number of times to try to connect to Parse Server.
    /// Defaults to 5.
    public internal(set) var maxConnectionAttempts: Int = 5

    internal var authentication: ((URLAuthenticationChallenge,
                                   (URLSession.AuthChallengeDisposition,
                                    URLCredential?) -> Void) -> Void)?
    internal var mountPath: String
    internal var isTestingSDK = false //Enable this only for certain tests like ParseFile

    /**
     Create a Parse Swift configuration.
     - parameter applicationId: The application id of your Parse application.
     - parameter clientKey: The client key of your Parse application.
     - parameter masterKey: The master key of your Parse application.
     - parameter serverURL: The server URL to connect to Parse Server.
     - parameter liveQueryServerURL: The live query server URL to connect to Parse Server.
     - parameter isAllowingCustomObjectIds: Allows objectIds to be created on the client.
     side for each object. Must be enabled on the server to work.
     - parameter isUsingTransactions: Use transactions when saving/updating multiple objects.
     - parameter isUsingEqualQueryConstraint: Use the **$eq** query constraint when querying.
     - parameter keyValueStore: A key/value store that conforms to the `ParseKeyValueStore`
     protocol. Defaults to `nil` in which one will be created an memory, but never persisted. For Linux, this
     this is the only store available since there is no Keychain. Linux users should replace this store with an
     encrypted one.
     - parameter requestCachePolicy: The default caching policy for all http requests that determines
     when to return a response from the cache. Defaults to `useProtocolCachePolicy`. See Apple's [documentation](https://developer.apple.com/documentation/foundation/url_loading_system/accessing_cached_data)
     for more info.
     - parameter cacheMemoryCapacity: The memory capacity of the cache, in bytes. Defaults to 512KB.
     - parameter cacheDiskCapacity: The disk capacity of the cache, in bytes. Defaults to 10MB.
     - parameter isMigratingFromObjcSDK: If your app previously used the iOS Objective-C SDK, setting this value
     to `true` will attempt to migrate relevant data stored in the Keychain to ParseSwift. Defaults to `false`.
     - parameter isDeletingKeychainIfNeeded: Deletes the Parse Keychain when the app is running for the first time.
     Defaults to `false`.
     - parameter httpAdditionalHeaders: A dictionary of additional headers to send with requests. See Apple's
     [documentation](https://developer.apple.com/documentation/foundation/urlsessionconfiguration/1411532-httpadditionalheaders)
     for more info.
     - parameter maxConnectionAttempts: Maximum number of times to try to connect to Parse Server.
     Defaults to 5.
     - parameter authentication: A callback block that will be used to receive/accept/decline network challenges.
     Defaults to `nil` in which the SDK will use the default OS authentication methods for challenges.
     It should have the following argument signature: `(challenge: URLAuthenticationChallenge,
     completionHandler: (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) -> Void`.
     See Apple's [documentation](https://developer.apple.com/documentation/foundation/urlsessiontaskdelegate/1411595-urlsession) for more for details.
     - warning: `isUsingTransactions` is experimental.
     */
    public init(applicationId: String,
                clientKey: String? = nil,
                masterKey: String? = nil,
                serverURL: URL,
                liveQueryServerURL: URL? = nil,
                allowCustomObjectId: Bool = false,
                isAllowingCustomObjectIds: Bool = false,
                isUsingTransactions: Bool = false,
                isUsingEqualQueryConstraint: Bool = false,
                keyValueStore: ParseKeyValueStore? = nil,
                requestCachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
                cacheMemoryCapacity: Int = 512_000,
                cacheDiskCapacity: Int = 10_000_000,
                isMigratingFromObjcSDK: Bool = false,
                isDeletingKeychainIfNeeded: Bool = false,
                httpAdditionalHeaders: [AnyHashable: Any]? = nil,
                maxConnectionAttempts: Int = 5,
                authentication: ((URLAuthenticationChallenge,
                                  (URLSession.AuthChallengeDisposition,
                                   URLCredential?) -> Void) -> Void)? = nil) {
        self.applicationId = applicationId
        self.clientKey = clientKey
        self.masterKey = masterKey
        self.serverURL = serverURL
        self.liveQuerysServerURL = liveQueryServerURL
        self.isAllowingCustomObjectIds = isAllowingCustomObjectIds
        self.isUsingTransactions = isUsingTransactions
        self.isUsingEqualQueryConstraint = isUsingEqualQueryConstraint
        self.mountPath = "/" + serverURL.pathComponents
            .filter { $0 != "/" }
            .joined(separator: "/")
        self.authentication = authentication
        self.requestCachePolicy = requestCachePolicy
        self.cacheMemoryCapacity = cacheMemoryCapacity
        self.cacheDiskCapacity = cacheDiskCapacity
        self.isMigratingFromObjcSDK = isMigratingFromObjcSDK
        self.isDeletingKeychainIfNeeded = isDeletingKeychainIfNeeded
        self.httpAdditionalHeaders = httpAdditionalHeaders
        self.maxConnectionAttempts = maxConnectionAttempts
        ParseStorage.shared.use(keyValueStore ?? InMemoryKeyValueStore())
    }
}

/**
 `ParseSwift` contains static methods to handle global configuration for the Parse framework.
 */
public struct ParseSwift {

    public internal(set) static var configuration: ParseConfiguration!
    static var sessionDelegate: ParseURLSessionDelegate!

    /**
     Configure the Parse Swift client. This should only be used when starting your app. Typically in the
     `application(... didFinishLaunchingWithOptions launchOptions...)`.
     - parameter configuration: The Parse configuration.
     */
    static public func initialize(configuration: ParseConfiguration) {
        Self.configuration = configuration
        Self.sessionDelegate = ParseURLSessionDelegate(callbackQueue: .main,
                                                       authentication: configuration.authentication)
        isDeletingKeychainIfNeeded()

        do {
            let previousSDKVersion = try ParseVersion(ParseVersion.current)
            let currentSDKVersion = try ParseVersion(ParseConstants.version)
            let oneNineEightSDKVersion = try ParseVersion("1.9.8")

            // All migrations from previous versions to current should occur here:
            #if !os(Linux) && !os(Android) && !os(Windows)
            if previousSDKVersion < oneNineEightSDKVersion {
                // Old macOS Keychain can't be used because it's global to all apps.
                _ = KeychainStore.old
                KeychainStore.shared.copy(keychain: KeychainStore.old)
                // Need to delete the old Keychain because a new one is created with bundleId.
                try? KeychainStore.old.deleteAll()
            }
            #endif
            if currentSDKVersion > previousSDKVersion {
                ParseVersion.current = currentSDKVersion.string
            }
        } catch {
            // Migrate old installations made with ParseSwift < 1.3.0
            if let currentInstallation = BaseParseInstallation.current {
                if currentInstallation.objectId == nil {
                    BaseParseInstallation.deleteCurrentContainerFromKeychain()
                    // Prepare installation
                    BaseParseInstallation.createNewInstallationIfNeeded()
                }
            } else {
                // Prepare installation
                BaseParseInstallation.createNewInstallationIfNeeded()
            }
            ParseVersion.current = ParseConstants.version
        }

        // Migrate installations with installationId, but missing
        // currentInstallation, ParseSwift < 1.9.10
        if let installationId = BaseParseInstallation.currentContainer.installationId,
           BaseParseInstallation.currentContainer.currentInstallation == nil {
            if let foundInstallation = try? BaseParseInstallation
                .query("installationId" == installationId)
                .first(options: [.cachePolicy(.reloadIgnoringLocalCacheData)]) {
                let newContainer = CurrentInstallationContainer<BaseParseInstallation>(currentInstallation: foundInstallation,
                                                                                       installationId: installationId)
                BaseParseInstallation.currentContainer = newContainer
                BaseParseInstallation.saveCurrentContainerToKeychain()
            }
        }
        BaseParseInstallation.createNewInstallationIfNeeded()

        #if !os(Linux) && !os(Android) && !os(Windows)
        if configuration.isMigratingFromObjcSDK {
            if let identifier = Bundle.main.bundleIdentifier {
                let objcParseKeychain = KeychainStore(service: "\(identifier).com.parse.sdk")
                guard let installationId: String = objcParseKeychain.object(forKey: "installationId"),
                      BaseParseInstallation.current?.installationId != installationId else {
                    return
                }
                var updatedInstallation = BaseParseInstallation.current
                updatedInstallation?.installationId = installationId
                BaseParseInstallation.currentContainer.installationId = installationId
                BaseParseInstallation.currentContainer.currentInstallation = updatedInstallation
                BaseParseInstallation.saveCurrentContainerToKeychain()
            }
        }
        #endif
    }

    /**
     Configure the Parse Swift client. This should only be used when starting your app. Typically in the
     `application(... didFinishLaunchingWithOptions launchOptions...)`.
     - parameter applicationId: The application id of your Parse application.
     - parameter clientKey: The client key of your Parse application.
     - parameter masterKey: The master key of your Parse application.
     - parameter serverURL: The server URL to connect to Parse Server.
     - parameter liveQueryServerURL: The live query server URL to connect to Parse Server.
     - parameter isAllowingCustomObjectIds: Allows objectIds to be created on the client.
     side for each object. Must be enabled on the server to work.
     - parameter isUsingTransactions: Use transactions when saving/updating multiple objects.
     - parameter isUsingEqualQueryConstraint: Use the **$eq** query constraint when querying.
     - parameter keyValueStore: A key/value store that conforms to the `ParseKeyValueStore`
     protocol. Defaults to `nil` in which one will be created an memory, but never persisted. For Linux, this
     this is the only store available since there is no Keychain. Linux users should replace this store with an
     encrypted one.
     - parameter requestCachePolicy: The default caching policy for all http requests that determines
     when to return a response from the cache. Defaults to `useProtocolCachePolicy`. See Apple's [documentation](https://developer.apple.com/documentation/foundation/url_loading_system/accessing_cached_data)
     for more info.
     - parameter cacheMemoryCapacity: The memory capacity of the cache, in bytes. Defaults to 512KB.
     - parameter cacheDiskCapacity: The disk capacity of the cache, in bytes. Defaults to 10MB.
     - parameter isMigratingFromObjcSDK: If your app previously used the iOS Objective-C SDK, setting this value
     to `true` will attempt to migrate relevant data stored in the Keychain to ParseSwift. Defaults to `false`.
     - parameter isDeletingKeychainIfNeeded: Deletes the Parse Keychain when the app is running for the first time.
     Defaults to `false`.
     - parameter httpAdditionalHeaders: A dictionary of additional headers to send with requests. See Apple's
     [documentation](https://developer.apple.com/documentation/foundation/urlsessionconfiguration/1411532-httpadditionalheaders)
     for more info.
     - parameter authentication: A callback block that will be used to receive/accept/decline network challenges.
     Defaults to `nil` in which the SDK will use the default OS authentication methods for challenges.
     It should have the following argument signature: `(challenge: URLAuthenticationChallenge,
     completionHandler: (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) -> Void`.
     See Apple's [documentation](https://developer.apple.com/documentation/foundation/urlsessiontaskdelegate/1411595-urlsession) for more for details.
     - warning: `isUsingTransactions` is experimental.
     */
    static public func initialize(
        applicationId: String,
        clientKey: String? = nil,
        masterKey: String? = nil,
        serverURL: URL,
        liveQueryServerURL: URL? = nil,
        isAllowingCustomObjectIds: Bool = false,
        isUsingTransactions: Bool = false,
        isUsingEqualQueryConstraint: Bool = false,
        keyValueStore: ParseKeyValueStore? = nil,
        requestCachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
        cacheMemoryCapacity: Int = 512_000,
        cacheDiskCapacity: Int = 10_000_000,
        isMigratingFromObjcSDK: Bool = false,
        isDeletingKeychainIfNeeded: Bool = false,
        httpAdditionalHeaders: [AnyHashable: Any]? = nil,
        maxConnectionAttempts: Int = 5,
        authentication: ((URLAuthenticationChallenge,
                          (URLSession.AuthChallengeDisposition,
                           URLCredential?) -> Void) -> Void)? = nil
    ) {
        initialize(configuration: .init(applicationId: applicationId,
                                        clientKey: clientKey,
                                        masterKey: masterKey,
                                        serverURL: serverURL,
                                        liveQueryServerURL: liveQueryServerURL,
                                        isAllowingCustomObjectIds: isAllowingCustomObjectIds,
                                        isUsingTransactions: isUsingTransactions,
                                        isUsingEqualQueryConstraint: isUsingEqualQueryConstraint,
                                        keyValueStore: keyValueStore,
                                        requestCachePolicy: requestCachePolicy,
                                        cacheMemoryCapacity: cacheMemoryCapacity,
                                        cacheDiskCapacity: cacheDiskCapacity,
                                        isMigratingFromObjcSDK: isMigratingFromObjcSDK,
                                        isDeletingKeychainIfNeeded: isDeletingKeychainIfNeeded,
                                        httpAdditionalHeaders: httpAdditionalHeaders,
                                        maxConnectionAttempts: maxConnectionAttempts,
                                        authentication: authentication))
    }

    internal static func initialize(applicationId: String,
                                    clientKey: String? = nil,
                                    masterKey: String? = nil,
                                    serverURL: URL,
                                    liveQueryServerURL: URL? = nil,
                                    isAllowingCustomObjectIds: Bool = false,
                                    isUsingTransactions: Bool = false,
                                    isUsingEqualQueryConstraint: Bool = false,
                                    keyValueStore: ParseKeyValueStore? = nil,
                                    requestCachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
                                    cacheMemoryCapacity: Int = 512_000,
                                    cacheDiskCapacity: Int = 10_000_000,
                                    isMigratingFromObjcSDK: Bool = false,
                                    isDeletingKeychainIfNeeded: Bool = false,
                                    httpAdditionalHeaders: [AnyHashable: Any]? = nil,
                                    maxConnectionAttempts: Int = 5,
                                    isTesting: Bool = false,
                                    authentication: ((URLAuthenticationChallenge,
                                                      (URLSession.AuthChallengeDisposition,
                                                       URLCredential?) -> Void) -> Void)? = nil) {
        var configuration = ParseConfiguration(applicationId: applicationId,
                                               clientKey: clientKey,
                                               masterKey: masterKey,
                                               serverURL: serverURL,
                                               liveQueryServerURL: liveQueryServerURL,
                                               isAllowingCustomObjectIds: isAllowingCustomObjectIds,
                                               isUsingTransactions: isUsingTransactions,
                                               isUsingEqualQueryConstraint: isUsingEqualQueryConstraint,
                                               keyValueStore: keyValueStore,
                                               requestCachePolicy: requestCachePolicy,
                                               cacheMemoryCapacity: cacheMemoryCapacity,
                                               cacheDiskCapacity: cacheDiskCapacity,
                                               isMigratingFromObjcSDK: isMigratingFromObjcSDK,
                                               isDeletingKeychainIfNeeded: isDeletingKeychainIfNeeded,
                                               httpAdditionalHeaders: httpAdditionalHeaders,
                                               maxConnectionAttempts: maxConnectionAttempts,
                                               authentication: authentication)
        configuration.isTestingSDK = isTesting
        initialize(configuration: configuration)
    }

    static internal func isDeletingKeychainIfNeeded() {
        #if !os(Linux) && !os(Android) && !os(Windows)
        // Clear items out of the Keychain on app first run.
        if UserDefaults.standard.object(forKey: ParseConstants.bundlePrefix) == nil {
            if Self.configuration.isDeletingKeychainIfNeeded {
                try? KeychainStore.old.deleteAll()
                try? KeychainStore.shared.deleteAll()
            }
            clearCache()
            // This is no longer the first run
            UserDefaults.standard.setValue(String(ParseConstants.bundlePrefix),
                                           forKey: ParseConstants.bundlePrefix)
            UserDefaults.standard.synchronize()
        }
        #endif
    }

    /**
     Update the authentication callback.
     - parameter authentication: A callback block that will be used to receive/accept/decline network challenges.
     Defaults to `nil` in which the SDK will use the default OS authentication methods for challenges.
     It should have the following argument signature: `(challenge: URLAuthenticationChallenge,
     completionHandler: (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) -> Void`.
     See Apple's [documentation](https://developer.apple.com/documentation/foundation/urlsessiontaskdelegate/1411595-urlsession) for more for details.
     */
    static public func updateAuthentication(_ authentication: ((URLAuthenticationChallenge,
                                                         (URLSession.AuthChallengeDisposition,
                                                          URLCredential?) -> Void) -> Void)?) {
        Self.sessionDelegate = ParseURLSessionDelegate(callbackQueue: .main,
                                                       authentication: authentication)
    }

    #if !os(Linux) && !os(Android) && !os(Windows)
    /**
     Delete the Parse iOS Objective-C SDK Keychain from the device.
     - note: ParseSwift uses a different Keychain. After migration, the iOS Objective-C SDK Keychain is no longer needed.
     - warning: The keychain cannot be recovered after deletion.
     */
    static public func deleteObjectiveCKeychain() throws {
        if let identifier = Bundle.main.bundleIdentifier {
            let objcParseKeychain = KeychainStore(service: "\(identifier).com.parse.sdk")
            try objcParseKeychain.deleteAll()
        }
    }
    #endif

    /**
     Manually remove all stored cache.
     - note: The OS typically handles this automatically.
     */
    static public func clearCache() {
        URLSession.parse.configuration.urlCache?.removeAllCachedResponses()
    }
}
