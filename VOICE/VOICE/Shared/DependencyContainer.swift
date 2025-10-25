//
//  DependencyContainer.swift
//  VOICE
//
//  Dependency injection container for app-wide services
//

import Foundation

final class DependencyContainer {
    // MARK: - Singletons
    
    static let shared = DependencyContainer()
    
    // MARK: - Infrastructure
    
    lazy var config: Config = DefaultConfig()
    lazy var logger: Logger = DefaultLogger()
    lazy var keychainService: KeychainService = DefaultKeychainService()
    
    // MARK: - Network
    
    lazy var httpClient: HTTPClient = {
        let baseClient = DefaultHTTPClient(
            config: config,
            keychainService: keychainService,
            logger: logger
        )
        
        // Wrap with auth interceptor for automatic token refresh
        return AuthInterceptor(
            httpClient: baseClient,
            keychainService: keychainService,
            logger: logger,
            config: config
        )
    }()
    
    // MARK: - Repositories
    
    lazy var authRepository: AuthRepository = AuthRepositoryImpl(
        httpClient: httpClient,
        logger: logger
    )
    
    lazy var profileRepository: ProfileRepository = ProfileRepositoryImpl(
        httpClient: httpClient,
        logger: logger
    )
    
    lazy var itemsRepository: ItemsRepository = ItemsRepositoryImpl(
        httpClient: httpClient,
        logger: logger
    )
    
    // MARK: - Use Cases
    
    lazy var authLoginUseCase: AuthLoginUseCase = DefaultAuthLoginUseCase(
        authRepository: authRepository,
        keychainService: keychainService,
        logger: logger
    )
    
    lazy var authLogoutUseCase: AuthLogoutUseCase = DefaultAuthLogoutUseCase(
        authRepository: authRepository,
        keychainService: keychainService,
        logger: logger
    )
    
    lazy var getCurrentUserUseCase: GetCurrentUserUseCase = DefaultGetCurrentUserUseCase(
        profileRepository: profileRepository,
        logger: logger
    )
    
    lazy var itemsListUseCase: ItemsListUseCase = DefaultItemsListUseCase(
        itemsRepository: itemsRepository,
        logger: logger
    )
    
    lazy var itemsCreateUseCase: ItemsCreateUseCase = DefaultItemsCreateUseCase(
        itemsRepository: itemsRepository,
        logger: logger
    )
    
    lazy var itemsUpdateUseCase: ItemsUpdateUseCase = DefaultItemsUpdateUseCase(
        itemsRepository: itemsRepository,
        logger: logger
    )
    
    lazy var itemsDeleteUseCase: ItemsDeleteUseCase = DefaultItemsDeleteUseCase(
        itemsRepository: itemsRepository,
        logger: logger
    )
    
    // MARK: - UI Adapter
    
    lazy var componentRegistry: ComponentRegistry = ComponentRegistryLoader.loadOrDefault()
    
    lazy var uiActionDispatcher: UIActionDispatcher = UIAdapter(
        registry: componentRegistry,
        authLoginUseCase: authLoginUseCase,
        authLogoutUseCase: authLogoutUseCase,
        itemsListUseCase: itemsListUseCase,
        itemsCreateUseCase: itemsCreateUseCase,
        itemsUpdateUseCase: itemsUpdateUseCase,
        itemsDeleteUseCase: itemsDeleteUseCase,
        getCurrentUserUseCase: getCurrentUserUseCase,
        logger: logger
    )
    
    // MARK: - Initialization
    
    private init() {
        logger.info("DependencyContainer initialized with environment: \(config.buildEnv.rawValue)", module: "App")
    }
}

